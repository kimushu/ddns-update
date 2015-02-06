module Services
  class IeServer < DDNSService
    def initialize(config)
      @config = config
    end

    def info
      puts(<<EOD)
ieServer Project (http://ieserver.net/)
  Host: #{@config[:host]}
EOD
    end

    def update(ip)
      acc,dom = @config[:host].split(".", 2)
      res = Net::HTTP.get_response_timeout(URI.parse(
        "http://ieserver.net/cgi-bin/dip.cgi?"+
          "username=#{acc}&"+
          "password=#{@config[:pass]}&"+
          "domain=#{dom}&"+
          "updatehost=1")).body
      # status=0 -- success (IP has not been changed)
      # status=1 -- success (IP has been changed)
      {:result => res.include?(" #{ip} "), :response => res}
    end
  end
  List["ieServer"] = IeServer
end
