#!/usr/bin/perl

# Copyright (c) 2009, Matthew Reath (mpreath@gmail.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY Matthew Reath ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

use Getopt::Std;
use Net::Telnet;

sub usage() {
  print "xpconfig.pl [-p] [-m] -v <range> [-s <shelf #>] -l <slot #> -t <type> -u <username> -d <password> <ip address>\n";
  print "-p\tThis option indicates that the VLANs are protected.\n";
  print "-m\tThis option indicates the XP card is the master for protection.\n";
  print "-v <range>\tSpecify the range of VLANs to provision on the card.\n";
  print "\t\t(example: 1-5,10,15,20,25-40)\n";
  print "-s <shelf #>\tIf this is a multishelf system, specify the shelf the card is in.\n";
  print "-l <slot #>\tSpecify the slot the card is in.\n";
  print "-t <type>\tSpecify type of card. Either 10g or ge.\n";
  print "-u <username>\tUsername used to access the ONS shelf.\n";
  print "-d <password>\tPassword used to access the ONS shelf.\n";
  print "<ip address>\tIP Address of the ONS shelf being accessed.\n";
  exit();
}

if( @ARGV > 0 ) {
  # we have arguments
  getopts('pms:l:v:t:u:d:');
}

if(!$opt_l) {
  usage();
}

if ($opt_t eq "10g") {
  # 10g card, trunk ports 3-1, 4-1
  @trunk_ports = ("3-1","4-1");
} elsif ($opt_t eq "ge") {
  @trunk_ports = ("21-1", "22-1");
} else {
  # print usage, incorrect card type
  usage();
}

@command_queue = ();

if($opt_u && $opt_d) {

$login_cmd = "ACT-USER::$opt_u:100::$opt_d;";
push(@command_queue, $login_cmd);

} else {
  usage();
}

# take the vlan range value, verify it matches regex
@vlan_range = ();

if ($opt_v =~ /[\d-,]+/) {

  # split the vlan range, store it temp
  @temp = split(',', $opt_v);


  foreach my $vlan (@temp) {
    if ($vlan =~ m/(\d+)-(\d+)/) {
      # extract values before the dash and after the dash, start and end
      push(@vlan_range, $1 .. $2);
    } else {
      push(@vlan_range, $vlan);
    }
  }

} else {
  usage();
}

foreach my $vlan (@vlan_range) {
  $vlan_cmd = "ENT-VLAN::VLAN-$vlan:1:::NAME=VLAN$vlan";
  if($opt_p) {
    $vlan_cmd = $vlan_cmd . ",PROTN=Y";
  }
  $vlan_cmd = $vlan_cmd . ";";
  push(@command_queue,$vlan_cmd);

  foreach my $trunk (@trunk_ports) {
    $port_name = "ETH-";
    if($opt_s) {
      # assumes multishelf if shelf is specified
      $port_name = $port_name . "$opt_s-";
    }
    
    $port_name = $port_name . "$opt_l-$trunk";

    $trunk_cmd = "ENT-NNI-ETH::$port_name:1::$vlan;";
    push(@command_queue,$trunk_cmd);
  }
}

if($opt_p) {
  $prot_cmd = "ED-EQPT::SLOT-";
  if($opt_s) {
    $prot_cmd = $prot_cmd . "$opt_s-";
  }

  $prot_cmd = $prot_cmd . "$opt_l:123:::FRPSTATE=ENABLED;";
  push(@command_queue,$prot_cmd);
}

if($opt_m) {
  $mast_cmd = "ED-EQPT::SLOT-";
  if($opt_s) {
    $mast_cmd = $mast_cmd . "$opt_s-";
  }

  $mast_cmd = $mast_cmd . "$opt_l:123:::FRPROLE=MASTER;";
  push(@command_queue,$mast_cmd);

  $port_name = "ETH-";
    if($opt_s) {
      # assumes multishelf if shelf is specified
      $port_name = $port_name . "$opt_s-";
    }
    
    $port_name = $port_name . "$opt_l-$trunk_ports[0]";

  $blk_cmd = "ED-L2-ETH::$port_name:123:::BRIDGESTATE=BLOCKING;";
  push(@command_queue,$blk_cmd);

}

$tmp = pop(@ARGV);

$telnet = new Net::Telnet( Timeout => 10,
Errmode => 'die');

print "Connecting to $tmp...";
$telnet->open(Host => $tmp,
Port => 3083);
print "Success!\n";
$telnet->waitfor('/>/i');
print "Running command queue...\n";
foreach my $cmd (@command_queue) {
  @lines = $telnet->cmd($cmd);
  foreach my $line (@lines) {
	print $line;
  }
}
print "\n";
$telnet->close();
print "Complete.\n";


#}
