#!/usr/bin/ruby

#
#    dsxloop.rb - Script for placing DSx ports in loopback for local
#    wire-wrap testing to a dsx panel. 
#
#    Copyright (C) 2009  Matthew Reath 
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'rubygems'
require 'progressbar'
require 'ons'

def usage
  puts "dsxloop.rb [-s <shelf #>] -l <slot #> -t <type> [-r] -u <username> -d <password> <ip address>\n";
  puts "-s <shelf #>\tIf this is a multishelf system, specify the shelf the car
d is in.\n";
  puts "-l <slot #>\tSpecify the slot the card is in.\n";
  puts "-t <type>\tSpecify type of card. (ds1-14,ds1-56,ds3-12, or ds3-48)\n";
  puts "-u <username>\tUsername used to access the ONS shelf.\n";
  puts "-d <password>\tPassword used to access the ONS shelf.\n";
  puts "-r\t\tRemoves the loopbacks and puts ports IS,AINS.\n";
  puts "<ip address>\tIP Address of the ONS shelf being accessed.\n";
end

#pbar = ProgressBar.new("Configuring", 100)

#100.times {sleep(0.1); pbar.inc}; pbar.finish


command_queue = Array.new
port_list = Array.new

# we need to iterate through the CLI arguments and assign the variables
type = nil
user = nil
password = nil
slot = nil
shelf = nil
ip_address = nil
reverse = nil

for i in 0...ARGV.length
	type = ARGV[i+1] if ARGV[i] =~ /-t/	
	user = ARGV[i+1] if ARGV[i] =~ /-u/
	password = ARGV[i+1] if ARGV[i] =~ /-d/
	slot = ARGV[i+1] if ARGV[i] =~ /-l/
	shelf = ARGV[i+1] if ARGV[i] =~ /-s/
	reverse = true if ARGV[i] =~ /-r/
	ip_address = ARGV[i] if i == ARGV.length-1 
end

#puts "Type:\t\t#{type}"
#puts "Shelf:\t\t#{shelf}" if shelf
#puts "Slot:\t\t#{slot}"
#puts "User:\t\t#{user}"
#puts "Password:\t#{password}"
#puts "IP:\t\t#{ip_address}:3083"


if user and password

else
	usage()
	exit()
end

#puts command_queue.shift

if shelf
	port_prefix = "FAC-#{shelf}-#{slot}"
else
	port_prefix = "FAC-#{slot}"
end


if type =~ /ds1-14/
	# create 14 ports, labeled properly
	1.upto(14) do |i|
		port_list.push( "#{port_prefix}-#{i}" )
	end
elsif type =~ /ds1-56/
	# create 56 ports, labeled properly
	1.upto(56) do |i|
		port_list.push( "#{port_prefix}-#{i}")
	end
elsif type =~ /ds3-12/
	# create 12 ports, labeled properly
	1.upto(12) do |i|
		port_list.push("#{port_prefix}-#{i}")
	end
elsif type =~ /ds3-48/
	# create 48 ports, labeled properly
	1.upto(48) do |i|
		port_list.push("#{port_prefix}-#{i}")
	end
else
	usage()
	exit()
end

# we have the ports created now we need to go through the array
# and put TL1 commands on the queue

port_list.each do |port|
	if type =~ /ds1/
		if reverse
			# remove the loopback
			command_queue.push( "RLS-LPBK-T1::#{port}:100::,,,FACILITY;")
			command_queue.push( "ED-T1::#{port}:101::::IS,AINS;")
		else 
			command_queue.push( "ED-T1::#{port}:100:::LINECDE=B8ZS,FMT=ESF:OOS,MT;")
			command_queue.push( "OPR-LPBK-T1::#{port}:101::,,,FACILITY;")
		end
	elsif type =~ /ds3/
		if reverse
			command_queue.push("RLS-LPBK-T3::#{port}:100::,,,FACILITY;")
			command_queue.push("ED-T3::#{port}:101::::IS,AINS;")
		else
			command_queue.push("ED-T3::#{port}:100::::OOS,MT;")
			command_queue.push("OPR-LPBK-T3::#{port}:101::,,,FACILITY;")
		end
	end

end

#command_queue.each do |command|
#	puts command;
#end

ons = ONS::TL1.new(ip_address, user, password)

begin
	ons.connect
	puts "Connected to #{ip_address}"
	pbar = ProgressBar.new("Loopback", command_queue.length)

	command_queue.each do |command|
		begin
			ons.send_command(command)
		rescue		
			puts ons.get_results()
		end
		
		pbar.inc
	end

	pbar.finish

	ons.disconnect

rescue
	puts "Failed to connect to #{ip_address}"
	puts ons.get_results()

end








