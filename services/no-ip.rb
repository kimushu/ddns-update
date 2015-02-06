module Services
  class NoIP < DDNSService
    def initialize(config)
      @config = config
    end

    def info
      puts(<<EOD)
No-IP service (http://www.noip.com/)
  User: #{@config[:user]}
  Host: #{@config[:host]}
EOD
    end

    def update(ip)
      res = Net::HTTP.get_response_timeout(URI.parse(
        "http://dynupdate.no-ip.com/update.php?"+
          "username=#{@config[:user]}&"+
          "pass=#{@config[:pass]}&"+
          "host=#{@config[:host]}&"+
          "ip=#{ip}")).body
      # status=0 -- success (IP has not been changed)
      # status=1 -- success (IP has been changed)
      {:result => !(res =~ /^status=[01]$/).nil?, :response => res}
    end
  end
  List["No-IP"] = NoIP
end
