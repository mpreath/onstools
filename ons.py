#!/usr/bin/python
#
#    ons.py - Python class for connecting to an ONS 15454 shelf and
#    sending/receiving data over Telnet 
#
#    Copyright (C) 2013  Matthew Reath 
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

import sys
import telnetlib

class ONS:
	"""A class for connection to a Cisco ONS shelf"""
	def __init__(self,ip_address, port, username, password):
	    self.ip_address = ip_address
	    self.port = port
	    self.username = username
	    self.password = password
	
        def connect(self):
            self.tn = telnetlib.Telnet()
            self.tn.open(self.ip_address,self.port)
            login_string = "ACT-USER::" + self.username + ":123::" + self.password + ";" 
            tn.read_until(">")
            results = self.send_command(login_string)

            return results

        def disconnect(self):
            self.tn.close()

        def send_command(self, command):

            tn.write(command)
            results = tn.read_until(">")

            return results

        def verify_results(self, results):

            return 0

        def get_neighbors(self):

            return 0

        def get_inventory(self):

            return 0



if __name__ == '__main__':

    ons = ONS("192.168.30.101","3033","CISCO15","otbu+1")
    results = ons.connect()
    print(results)
    results = ons.send_command("RTRV-MAP-NETWORK:::124;")
    print(results)
    
        


            



