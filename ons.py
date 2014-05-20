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
    
    def __init__(self):
        self.tn = telnetlib.Telnet()
        self.logged_in = 0
    
    def connect(self,host,port,user,pass):
        self.tn.open(host,port)
        # read until prompt
        
        # execute ACT-USER TL1 command
        # ACT-USER::username:123::password;
        # verify we are logged in successfully
        
    def send_command(self,cmd):
        
        
        # check the results, return the response
        return check_results(results)
    def get_results(self):
        
    def disconnect(self):
    
    def check_results(self,results):
        
    
    
    
        