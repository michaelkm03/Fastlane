//
//  StreamPaginator.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

final public class StreamPaginator: Paginator {
    
    public enum Macro: String {
        case PageNumber     = "%%PAGE_NUM%%"
        case ItemsPerPage   = "%%ITEMS_PER_PAGE%%"
        case SequenceID     = "%%SEQUENCE_ID%%"
        
        static var all: [Macro] {
            return [ .PageNumber, .ItemsPerPage, .SequenceID ]
        }
    }
    
    public let apiPath: String
    public let sequenceID: String?
    
    /// This Paginator requires knowing the result count of the previous request
    /// in order to determine if there are more pages to load, therefore tracking that
    /// value in this operation is required when paginated.
    public var resultCount: Int = 0
    
    public init?(apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.apiPath = apiPath
        self.sequenceID = sequenceID
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
        
        if apiPath.containsString( Macro.SequenceID.rawValue ) && sequenceID == nil {
            return nil
        }
    }
    
    // MARK: - Paginator
    
    public let pageNumber: Int
    public let itemsPerPage: Int
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        request.URL = urlWithMacrosReplaced( apiPath, sequenceID: sequenceID, pageNumber: pageNumber, itemsPerPage: itemsPerPage )
    }
    
    public func previousPage() -> StreamPaginator? {
        if pageNumber > 1 {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func nextPage() -> StreamPaginator? {
        if resultCount >= itemsPerPage {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    private func urlWithMacrosReplaced( apiPath: String, sequenceID: String?, pageNumber: Int = 1, itemsPerPage: Int = 15) -> NSURL? {
        var apiPathWithMacrosReplaced = apiPath
        for macro in Macro.all where apiPath.containsString(macro.rawValue) {
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
