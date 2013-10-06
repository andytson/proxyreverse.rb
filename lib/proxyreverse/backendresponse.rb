module ProxyReverse
  class BackendResponse
    def initialize(client, request)
      @parser = HTTP::ResponseParser.new(self)
      @client = client
      @request = request
    end

    def receive_data(data)
      @parser << data
    end
    
    def on_message_begin
      @headers = nil
      @body = ''
      @transferEncoding = 'identity'
      @contentEncoding = 'identity'
      @complete = false
    end
  
    def on_headers_complete(env)
      @headers = @parser.headers
      @host = @headers['Host']
      @transferEncoding = 'identity'
      @contentEncoding = 'identity'

      if @client.options[:rewrite_host] && @headers.has_key?('Location')
        @headers['Location'] = @headers['Location'].sub(/^(https?:\/\/)#{Regexp.escape(@client.options[:backend_host])}/, "\\1#{@request.host}")
      end

      if @headers.has_key?('Content-Encoding')
        @contentEncoding = @headers['Content-Encoding']
      end
      
      if @headers.has_key?('Transfer-Encoding')
        @transferEncoding = @headers['Transfer-Encoding']
      end
      @headers['Transfer-Encoding'] = 'chunked'
      @headers.delete('Content-Length')
       
      buf = "HTTP/#{@parser.http_version.join('.')} #{@parser.status_code} Message missing\r\n"
      @headers.each_pair do |name, value|
        buf << "#{name}: #{value}\r\n"
      end
      buf << "\r\n"
       
      @client.send_data(buf)
    end
  
    def on_body(chunk)
      @body << chunk
    end
  
    def on_message_complete
      case @contentEncoding
      when 'gzip'
        reader = Zlib::GzipReader.new(StringIO.new(@body))
        new_response_body = reader.read
        reader.close
        @body = new_response_body
      when 'deflate'
        @body = Zlib::Inflate.inflate(@body)
      end
      @body = @body.gsub(/(https?:\/\/)#{Regexp.escape(@client.options[:backend_host])}/, "\\1#{@request.host}")
      
      case @contentEncoding
      when 'gzip'
        new_response_body = ''
        writer = Zlib::GzipWriter.new(StringIO.new(new_response_body))
        writer.write(@body)
        writer.close
        @body = new_response_body
      when 'deflate'
        @body = Zlib::Deflate.deflate(@body)
      end
      
      if @body.length > 0
         @client.send_data "#{@body.length.to_s(16)}\r\n#{@body}\r\n0\r\n\r\n"
      else
         @client.send_data "0\r\n\r\n"
      end
      @complete = true
    end
    
    def complete?
      @complete
    end
  end
end