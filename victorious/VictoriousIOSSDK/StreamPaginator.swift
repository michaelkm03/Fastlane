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
        
        public static var all: [Macro] {
            return [ .PageNumber, .ItemsPerPage, .SequenceID ]
        }
    }
    
    /// This Paginator requires knowing the result count of the previous request
    /// in order to determine if there are more pages to load, therefore tracking that
    /// value in this operation is required when paginated.
    public var resultCount: Int = 0
    public let pageNumber: Int
    public let itemsPerPage: Int
    public let apiPath: String
    public let sequenceID: String?
    
    private let urlMacroReplacer = VSDKURLMacroReplacement()
    
    public init?(apiPath: String, sequenceID: String? = nil, pageNumber: Int = 1, itemsPerPage: Int = 15) {
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
            dictionary[ Macro.SequenceID.rawValue ] = sequenceID
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
    
    public func nextPage() -> StreamPaginator? {
        if resultCount >= itemsPerPage {
            return StreamPaginator(apiPath: apiPath, sequenceID: sequenceID, pageNumber: pageNumber + 1, itemsPerPage: itemsPerPage)
        }
        return nil
    }
}
