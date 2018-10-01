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
    def get_neighbors(self):
        cmd_results = self.send_command("RTRV-MAP-NETWORK:::124;")
        if(cmd_results):
            # lets split the results
            #print cmd_results
            matchobj = re.findall('\"(.*),(.*),(.*)\"',cmd_results)
            return matchobj
        else:
            return ''
        
    @classmethod
    def get_inventory(self):
        cmd_results = self.send_command("RTRV-INV::ALL:125;")

        if(cmd_results):
            #print cmd_results
            #print cmd_results
            inv_lookup_all = {}
            inv_index = 0
            matchobj = re.findall('\s+\"(.*)\"',cmd_results)
            for line in matchobj:
                matchobj2 = re.split(',', line)
                inv_lookup = {}
                index = 1
                for inv in matchobj2:
                    # first is location/slot
                    # second is CARD::PN=value
                    # the remaining are key=value pairs, need to parse and create object for lookup
                    if (index == 1):
                        inv_lookup['LOCATION'] = inv
                    elif (index == 2):
                        keyvalue = re.split('=',inv)
                        value = keyvalue[1]
                        key = re.split('::', keyvalue[0])
                        inv_lookup[key[1]] = value

                    else:
                        # parse key value pair, put in hash lookup
                        keyvalue = re.split('=',inv)
                        if(keyvalue[0]): # make sure its not empty
                            inv_lookup[keyvalue[0]] = keyvalue[1]
                    index = index + 1

                # do something with inventory data, pack into a
                inv_lookup_all[inv_index] = inv_lookup
                inv_index = inv_index + 1
                
            return inv_lookup_all
        else:
            return ''
    
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