module Services
  class DynamicDOjp < DDNSService
    def initialize(config)
      @config = config
    end

    def info
      puts(<<EOD)
Dynamic DO!.jp (http://ddo.jp/) by FURUKAWA System Design
  User: #{@config[:user]}
  Host: #{@config[:host]}
EOD
    end

    def update(ip)
      acc,dom = @config[:host].split(".", 2)
      res = Net::HTTP.get_response_timeout(URI.parse(
        "http://free.ddo.jp/dnsupdate.php?"+
          "dn=#{@config[:host]}&"+
          "pw=#{@config[:pass]}")).body
      {:result => (res =~ /SUCCESS: #{@config[:host]}/) ? true : false, :response => res}
    end
  end
  List["DynamicDO.jp"] = DynamicDOjp
end
