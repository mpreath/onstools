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

import ons

HOST = "192.168.30.2"
PORT = 3083
USERNAME = "CISCO15"
PASSWORD = "otbu+1"

ons = ons.ONS()
if(ons.connect(HOST,PORT,USERNAME,PASSWORD)):
    print "Connection to " + HOST + "[" + PORT + "] established"
else:
    print "Connection to " + HOST + "[" + PORT + "] failed"
    exit()
    
results = ons.send_command("RTRV-MAP-NETWORK:::124;")





ons.disconnect()
