//
//  WebViewHTMLFetchRequest
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct WebViewHTMLFetchRequest: RequestType {
    private let fullURL: NSURL
    public var urlRequest: NSURLRequest
    public var publicBaseURL: NSURL?
    
    public init(urlPath: String) {
        guard let url = NSURL(string: urlPath) else {
            fatalError("Invalid Fetch URL" + urlPath)
        }
        fullURL = url
        urlRequest = NSURLRequest(url: fullURL as URL)
        
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
    
    public func parseResponse(response: URLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> String {
        guard let htmlString = String(data: responseData as Data, encoding: String.Encoding.utf8) else {
            throw ResponseParsingError()
        }
        return htmlString
    }
}
