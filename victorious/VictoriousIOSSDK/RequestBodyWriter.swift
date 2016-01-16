//
//  RequestBodyWriter.swift
//  victorious
//
//  Created by Patrick Lynch on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that represents the output of a `RequestBodyWriterType`
protocol RequestBodyType {
    var fileURL: NSURL { get }
    var contentType: String { get }
}

/// Defines an object that will provude
protocol RequestBodyWriterType: class {
    
    typealias RequestBody: RequestBodyType
    typealias CreationParameters
    
    /// Writes a post body for an HTTP request to a temporary file and returns the URL of that file.
    func write(parameters parameters: CreationParameters) throws -> RequestBody
}
