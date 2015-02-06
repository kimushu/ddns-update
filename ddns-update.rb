#!/usr/bin/env ruby
require "net/http"
require "net/https"
require "cgi"
require "uri"
require "yaml"
require "base64"

class Hash
  def symbolize_keys!
    keys.each {|key|
      self[(key.intern rescue nil) || key] = delete(key)
    }
    self
  end
end

module Services
  class DDNSService
    def update(ip)
      {:result => false}
    end
  end
  List = {}
end

module Net
  class HTTP
    def self.get_response_timeout(uri, timeout = 30)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = timeout
      http.start rescue return nil
      http.read_timeout = timeout
      http.post(uri.path, uri.query) rescue return nil
    end
  end
end

require "./services/no-ip"
require "./services/ieserver"
require "./services/dynamic-do.jp"

config = YAML::load_file("./config.yml")
config.symbolize_keys!

ip = nil
config[:ip_check_sites].each {|site|
  resp = Net::HTTP.get_response_timeout(URI.parse(site))
  if(resp and resp.body =~ /\b(\d+\.\d+\.\d+\.\d+)\b/)
    ip = $1
    break
  end
  STDERR.puts("Cannot get IP address from #{site}")
}
abort "IP address is unknown" unless ip

config[:hosts].each {|sconf|
  sconf.symbolize_keys!
  sname = sconf[:service]
  sconf[:pass] ||= Base64.decode64(sconf[:pass64])
  sclass = Services::List[sname]
  # p [sclass, sconf]
  unless(sclass)
    STDERR.puts("No such service: #{sname}")
    next
  end
  service = sclass.new(sconf)
  result = service.update(ip)
  # p result
}

