# 
#    ons.rb - ONS class for connecting to the TL1 interface of 
#    Cisco's ONS 15xxx series products. 
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


require 'net/telnet'
module ONS
  class TL1
    def initialize(ip, user, pass)
      @ip = ip
      @user = user
      @pass = pass
    end

    def connect()
      @tn = Net::Telnet.new("Host"	=> @ip,
      "Port"	=> 3083)

      @results = @tn.waitfor(/^> /n)	

      if send_command("ACT-USER::#{@user}:123::#{@pass};")
        # login was successful
        return true
      else
        # login failed
        #print @results
        disconnect
        return false
      end
    end

    def send_command(cmd) 
      # send command through telnet
      @tn.print(cmd)
      @results = @tn.waitfor(/^> /n)
      # check results for errors
      #return check_results
      return check_results()	
    end

    def get_results()
      return @results
    end	

    def disconnect()
      # disconnect from host
      @tn.close
      #print "\nConnection to #{@ip} closed...\n"
    end

    private
    def check_results()
      # lets parse through the results, look for COMPLD 
      # for success, if nots found, fail
      if @results =~ /DENY/
        return false
      else
        return true
      end

    end

  end
end
