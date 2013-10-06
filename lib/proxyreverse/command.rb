require 'rubygems'
require 'optparse'
require 'yaml'

proxyreverse_path = File.expand_path('../../lib', __FILE__)
$:.unshift(proxyreverse_path) if File.directory?(proxyreverse_path) && !$:.include?(proxyreverse_path)

require 'proxyreverse'

default_options = {
  :backend_host => '127.0.0.1',
  :backend_port => '80',
  :host => '0.0.0.0',
  :port => '80',
  :rewrite_domain => false,
  :verbose => false
}

options = {}

begin
  cmd_args = OptionParser.new do |opts|
    opts.banner = 'Usage: proxyreverse [options] [PORT] [BACKEND]'

    opts.on('-r', '--rewrite-domain HOST', 'Domain to rewrite, .domain will include sub-domains') do |domain|
      options[:rewrite_domain] = domain
    end

    opts.on('-s', '--rewrite-subdomains', 'Rewrite all subdomains') do |domain|
      options[:rewrite_domain] = :subdomains
    end

    opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
      options[:verbose] = v
    end

    opts.on_tail("--version", "Show version") do
      puts ProxyReverse::VERSION
      exit
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end.parse!
rescue OptionParser::MissingArgument => e
  puts e
  exit
rescue OptionParser::InvalidOption => e
  puts e
  exit
end

options[:port] = cmd_args[0]

if cmd_args[1] =~ /^\d+$/
  options[:backend_port] = cmd_args[1]
elsif cmd_args[1] =~ /^([^:]+)(?::(\d+))?/
  default_options[:rewrite_domain] = $1
  options[:backend_host] = $1
  options[:backend_port] = $2
else
  puts "Error: invalid backend syntax, expecting host/host:port/port"
  exit
end

options[:version] = ProxyReverse::VERSION
options.delete_if { |k, v| v.nil? }

ProxyReverse::Client.run(default_options.merge(options))
