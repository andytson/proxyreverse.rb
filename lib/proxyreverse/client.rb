require 'logger'
require 'em-proxy'
require 'http/parser'
require 'zlib'

module ProxyReverse
  class Client < EventMachine::ProxyServer::Connection
    attr_accessor :options
    
    def self.run(options = {})
      @@logger = Logger.new(STDOUT)
      @@logger.level = options[:verbose] ? Logger::INFO : Logger::WARN

      @@logger.info("Run with options #{options.inspect}")

      begin
        trap 'SIGCLD', 'IGNORE'
        trap 'INT' do
          puts
          EventMachine.stop
          exit
        end
      rescue ArgumentError
      end

      EventMachine.epoll
      EventMachine.run { connect(options) }
    end
    
    def initialize(options)
      super(:debug => false)
      @options = options
      @responses = {}
      transferEncoding = 'identity'

      if @options[:rewrite_domain][0] == '.'
        @options['regex'] = "(https?:\\/\\/)([a-z\.]+\\.)?#{Regexp.escape(@options[:rewrite_domain][1..-1])}"
      else
        @options['regex'] = "(https?:\\/\\/)#{Regexp.escape(@options[:rewrite_domain])}"
      end

      server :srv, :host => @options[:backend_host], :port => @options[:backend_port]
    end
    
    def self.connect(options)
      EventMachine::start_server(options[:host], options[:port], self, options)
    end
    
    def connected(name)
    end

    def relay_from_backend(name, data)
      begin
        while data.length > 0
          if @responses[name].nil? || @responses[name].complete?
            @responses[name] = ProxyReverse::BackendResponse.new(self, @request)
          end
          offset = @responses[name].receive_data(data)
          data = data[offset..-1]
        end
      rescue HTTP::Parser::Error => e
        raise e if e.message != 'Could not parse data entirely'
      end
    end

    def receive_data(data)
      begin
        while data.length > 0
          if @request.nil? || @request.complete?
            @request = ProxyReverse::FrontendRequest.new(self)
          end
          offset = @request.receive_data(data)
          data = data[offset..-1]
        end
      rescue HTTP::Parser::Error => e
        raise e if e.message != 'Could not parse data entirely'
      end
    end
  end
end