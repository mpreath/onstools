# This file is part of onstools.
# 
# onstools is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# onstools is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with onstools.  If not, see <http://www.gnu.org/licenses/>.

import sys
import telnetlib

class ONS:
    """A class for connecting to the Cisco ONS 153xx,15454,15600,M6,M12,and NCS platforms
    via TL1 and automating tasks"""
    @classmethod
    def __init__(self):
        self.tn = telnetlib.Telnet()
        self.logged_in = 0
    
    @classmethod
    def connect(self,host,port,user,password):
        self.tn.open(host,port)
        # read until prompt
        all_results = self.tn.read_until('>')
        cmd = "ACT-USER::" + user + ":123::" + password + ";"
        # execute ACT-USER TL1 command
        return(self.check_results(self.send_command(cmd)))
        
    @classmethod    
    def send_command(self,cmd):
        
        #print "******" + cmd + "*********"
        self.tn.write(cmd + "\n\n")
        # need to read to the > prompt and stop
        all_results = self.tn.read_until('>')
        # check the results, return the response
        #print all_results
        return self.check_results(all_results)
    
    @classmethod
    def disconnect(self):
        self.tn.close()
    
    @classmethod
    def check_results(self,results):
        #verify it was successful, return '' if not, return the results if it is
        if("COMPLD" in results):
            return results
        else:
            return ''