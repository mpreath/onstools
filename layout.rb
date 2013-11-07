#!/usr/bin/ruby

# layout.rb - Script for displaying the shelf type and card layout of
# an ONS system. 
# 
# Copyright (C) 2012 Matthew Reath
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require 'rubygems'
require 'progressbar'
require 'ons'

def usage
  puts "dsxloop.rb -u <username> -d <password> <ip address>\n";
  puts "-u <username>\tUsername used to access the ONS shelf.\n";
  puts "-d <password>\tPassword used to access the ONS shelf.\n";
  puts "<ip address>\tIP Address of the ONS shelf being accessed.\n";
end


