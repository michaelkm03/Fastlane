require 'httparty'

module VAMS
  module HTTP
    extend self

    def send_request_to_uri(type:, uri:, query:{}, headers:{}, body:{})
      send_request(type:     type,
                   protocol: uri.scheme,
                   host:     uri.host,
                   path:     uri.path,
                   query:    query,
                   headers:  headers,
                   body:     body)
    end

    def send_request(type:, protocol: 'https', host:, path:, query:{}, headers: {}, body: {})
      HTTParty.send(type.to_sym,
                    protocol + '://' + host + path,
                    { headers: headers, query: query, body: body })
    end
  end
end
