#!/usr/bin/python

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

#!/usr/bin/python

import sys, getopt, ons, time, re

def main(argv):
       
    hostname = ''
    port = 3083
    username = ''
    password = ''
   
    try:
        opts, args = getopt.getopt(argv,"h:u:p:",["hostname=","username=","password="])
    except getopt.GetoptError:
        print 'discover.py -h hostname -u <username> -p <password>'
        sys.exit(2)
    
    if (len(opts) != 3):
        print 'discover.py -h hostname -u <username> -p <password>'
        sys.exit(2)
    
    for opt, arg in opts:
        if opt in ('-h', "--hostname"):
            hostname = arg
        elif opt in ("-u", "--username"):
            username = arg
        elif opt in ("-p", "--password"):
            password = arg
        else:
            print 'discover.py -h hostname -u <username> -p <password>'
            sys.exit(2) 
          
    # start script code here
    myons = ons.ONS()
    myons.connect(hostname,port,username,password)
    #time.sleep(5)

    # ons.get_neighbors - returns an array of tuplets (IP Address, Name, Type)
    
    neighbors = myons.get_neighbors()
    
    #print matchobj
    for neighbor in neighbors:
        print("{: <20} {: <20} {: <20}".format(*neighbor))
    
    
    myons.disconnect()
    


if __name__ == "__main__":
   main(sys.argv[1:])
