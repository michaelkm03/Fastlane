require 'httparty'

module VAMS
  module HTTP
    extend self

    def send_request_to_uri(type:, uri:, options:{}, headers:{}, body:{})
      send_request(type:     type,
                   protocol: uri.scheme,
                   host:     uri.host,
                   path:     uri.path,
                   options:  options,
                   headers:  headers,
                   body:     body)
    end

    def send_request(type:, protocol: 'https', host:, path:, options:{}, headers: {}, body: {})
      HTTParty.send(type.to_sym, protocol + '://' + host + path, headers: headers, query: options, body: body)
    end
  end
end
