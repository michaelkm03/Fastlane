//
//  StreamPaginator.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct StreamPaginator: Paginator {
    
    public enum Macro: String {
        case PageNumber     = "%%PAGE_NUM%%"
        case ItemsPerPage   = "%%ITEMS_PER_PAGE%%"
        case SequenceID     = "%%SEQUENCE_ID%%"
        
        public static var all: [Macro] {
            return [ .PageNumber, .ItemsPerPage, .SequenceID ]
        }
    }
    
    public let pageNumber: Int
    public let itemsPerPage: Int
    public let apiPath: String
    public let sequenceID: Int64?
    
    private let urlMacroReplacer = VSDKURLMacroReplacement()
    
    public init?(apiPath: String, sequenceID: Int64? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.apiPath = apiPath
        self.sequenceID = sequenceID
        self.pageNumber = pageNumber
        self.itemsPerPage = itemsPerPage
        
        if apiPath.containsString( Macro.SequenceID.rawValue ) && sequenceID == nil {
            print( "\(self.dynamicType) :: Failed to create instance because the provided `apiPath` contains a \"\(Macro.SequenceID.rawValue)\" macro but no `sequenceID` value was provided.")
            return nil
        }
    }
    
    // MARK: - Paginator protocol
    
    public func addPaginationArgumentsToRequest(request: NSMutableURLRequest) {
        var dictionary: [NSObject : AnyObject] = [
            Macro.PageNumber.rawValue : String(pageNumber),
            Macro.ItemsPerPage.rawValue : String(itemsPerPage)
        ]
        if let sequenceID = sequenceID {
            dictionary[ Macro.SequenceID.rawValue ] = String(sequenceID)
        }
        if let urlString = urlMacroReplacer.urlByReplacingMacrosFromDictionary( dictionary, inURLString: apiPath) {
            request.URL = NSURL(string: urlString)
        }
    }
    
    public func previousPage() -> StreamPaginator? {
        if pageNumber > 1 {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber - 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
    
    public func nextPage( resultCount: Int ) -> StreamPaginator? {
        if resultCount > 0 {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
}
