#!/usr/bin/ruby

#
#    discover.rb - Connects to ONS shelf and gathers information
#    regarding other connected nodes 
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
  puts "discover.rb -u <username> -d <password> <ip address>\n";
  puts "-u <username>\tUsername used to access the ONS shelf.\n";
  puts "-d <password>\tPassword used to access the ONS shelf.\n";
  puts "<ip address>\tIP Address of the ONS shelf being accessed.\n";
end

# initialize the command queue
command_queue = Array.new
# initialize the port list
node_list = Array.new

# we need to iterate through the CLI arguments and assign the variables
user = nil
password = nil
ip_address = nil

for i in 0...ARGV.length
	user = ARGV[i+1] if ARGV[i] =~ /-u/
	password = ARGV[i+1] if ARGV[i] =~ /-d/
	ip_address = ARGV[i] if i == ARGV.length-1 
end

# verify user and password were specified
if user and password

else
	usage()
	exit()
end

gather_cmd = "RTRV-MAP-NETWORK:::123;"
ons = ONS::TL1.new(ip_address, user, password)

begin
# connect to the ONS shelf
	ons.connect
	#puts "Connected to #{ip_address}"
	#pbar = ProgressBar.new("Loopback", command_queue.length)

	ons.send_command(gather_cmd)
	disc_out =  ons.get_results()
#	puts ons.get_results()

	# parse the results

	# look for "x.x.x.x,name,type" triplets
	
	node_list = disc_out.scan(/\"(.+),(.+),(.+)\"/)

	node_list.each do |node|
		puts "#{node[1]} [#{node[0]}] [#{node[2]}]"
		# 1 - node name
		# 0 - ip address
		# 2 - type


		#puts "Gathering inventory on #{node[1]}"
	end
rescue

	#pbar.finish

	ons.disconnect
	# ERROR - WE COULDN'T CONNECT
	puts "Failed to connect to #{ip_address}"
	puts ons.get_results()

end








