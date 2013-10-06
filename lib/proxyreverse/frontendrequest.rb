module ProxyReverse
  class FrontendRequest
    attr_accessor :host

    def initialize(client)
      @parser = HTTP::RequestParser.new(self)
      @client = client
    end

    def receive_data(data)
      @parser << data
    end
    
    def on_message_begin
      @headers = nil
      @body = ''
      @complete = false
    end
  
    def on_headers_complete(env)
      @headers = @parser.headers
      @host = @headers['Host']
      @transferEncoding = 'identity'

      if @client.options[:rewrite_domain]
        @headers['Host'] = @client.options[:backend_host]
      end
      
      if @headers.has_key?('Transfer-Encoding')
        @transferEncoding = @headers['Transfer-Encoding']
      end
       
      buf = "#{@parser.http_method} #{@parser.request_path} HTTP/#{@parser.http_version.join('.')}\r\n"
      @headers.each_pair do |name, value|
        buf << "#{name}: #{value}\r\n"
      end
      buf << "\r\n"
       
      @client.relay_to_servers(buf)
    end
  
    def on_body(chunk)
      client.relay_to_servers(chunk)
    end
  
    def on_message_complete
      @complete = true
    end
    
    def complete?
      @complete
    end
  end
end