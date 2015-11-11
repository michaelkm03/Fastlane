//
//  StandardPaginator.swift
//  victorious
//
//  Created by Josh Hinman on 11/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct StandardPaginator {
    
    public let pageNumber: Int
    public let itemsPerPage: Int
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        request.URL = request.URL?.URLByAppendingPathComponent(String(pageNumber)).URLByAppendingPathComponent(String(itemsPerPage))
    }
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
    }
    
    public var previousPage: StandardPaginator? {
        if pageNumber > 1 {
            return StandardPaginator(pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public var nextPage: StandardPaginator {
        return StandardPaginator(pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
    }
}

enum StreamURLMacros: String {
    
    case PageNumber     = "%%PAGE_NUM%%"
    case ItemsPerPage   = "%%ITEMS_PER_PAGE%%"
    case SequenceID     = "%%SEQUENCE_ID%%"
    
    static var all: [StreamURLMacros] {
        return [ .PageNumber, .ItemsPerPage, .SequenceID ]
    }
    
    static func urlWithMacrosReplaced( apiPath: String, sequenceID: String?, pageNumber: Int = 1, itemsPerPage: Int = 15) -> NSURL? {
        var apiPathWithMacrosReplaced = apiPath
        for macro in StreamURLMacros.all where apiPath.containsString(macro.rawValue) {
            switch macro {
            case .PageNumber:
                apiPathWithMacrosReplaced = apiPathWithMacrosReplaced.stringByReplacingOccurrencesOfString(macro.rawValue, withString: String(pageNumber))
            case .ItemsPerPage:
                apiPathWithMacrosReplaced = apiPathWithMacrosReplaced.stringByReplacingOccurrencesOfString(macro.rawValue, withString: String(itemsPerPage))
            case .SequenceID:
                guard let sequenceID = sequenceID else {
                    return nil
                }
                apiPathWithMacrosReplaced = apiPathWithMacrosReplaced.stringByReplacingOccurrencesOfString(macro.rawValue, withString: sequenceID)
            }
        }
        return NSURL(string: apiPathWithMacrosReplaced)
    }
}
