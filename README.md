# ProxyReverse

ProxyReverse proxies your local web-server and makes it act as if
coming from your local host, rewriting the response, so that links
stay inside the proxy domain

## Installation

ProxyReverse is a tool that runs on the command line.

On any system with [ruby] and [rubygems] installed, open your terminal
and type:

    $ gem install proxyreverse

## Usage

Assuming that you are running your local web-server on a VM with a host-only
interface with local access via http://my.dev/

    $ proxyreverse 8080 my.dev
    http://my.dev is now publicly available via:
    http://localhost:8080/

Now you can open this link in your favorite browser and request will
be proxied to your local VM.

[ruby]: http://www.ruby-lang.org/en/downloads/
[rubygems]: https://rubygems.org/pages/download
[github]: https://github.com/andytson/proxyremote
