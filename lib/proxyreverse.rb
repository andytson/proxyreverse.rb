require 'proxyreverse/version'

module ProxyReverse
  autoload :Client, 'proxyreverse/client'
  autoload :FrontendRequest, 'proxyreverse/frontendrequest'
  autoload :BackendResponse, 'proxyreverse/backendresponse'
  autoload :Command, 'proxyreverse/command'

  class << self
    def logger
      @@logger ||= nil
    end

    def logger=(logger)
      @@logger = logger
    end
  end
end
