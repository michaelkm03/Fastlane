//
//  WebViewHTMLFetchRequest
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct WebViewHTMLFetchRequest: RequestType {
    private let fullURL: URL
    public var urlRequest: URLRequest
    public var publicBaseURL: URL?
    
    public init(urlPath: String) {
        guard let url = URL(string: urlPath) else {
            fatalError("Invalid Fetch URL" + urlPath)
        }
        fullURL = url
        urlRequest = URLRequest(url: fullURL)
        
        if let hostString = fullURL.host {
            let urlComponents = NSURLComponents()
            urlComponents.scheme = fullURL.scheme
            urlComponents.host = hostString
            
            if let baseURL = urlComponents.url {
                publicBaseURL = baseURL
            }
        }
    }
    
    public var providesFullURL = true
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> String {
        guard let htmlString = String(data: responseData as Data, encoding: String.Encoding.utf8) else {
            throw ResponseParsingError()
        }
        return htmlString
    }
}
