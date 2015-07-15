//
//  VObjectManager+GIFSearch.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

// Provides methods for searching for GIFs through the backend
extension VObjectManager {
    
    typealias GIFSearchSuccess = (results: [GIFSearchResult]) -> ()
    
    typealias GIFSearchFailure = (error: NSError?, cancelled: Bool) -> ()
    
    func searchForGIF( keywords: [String], pageType:VPageType, success:GIFSearchSuccess?, failure:GIFSearchFailure? ) -> RKManagedObjectRequestOperation? {
        
        let keywordList: String = join( ",", keywords )
        let charSet = NSCharacterSet.alphanumericCharacterSet()
        let escapedKeywordList = keywordList.stringByAddingPercentEncodingWithAllowedCharacters( charSet )!
        
        var filter = self.filterForKeywords( escapedKeywordList )
        if !filter.canLoadPageType( pageType ) || self.paginationManager.isLoadingFilter( filter ) {
            return nil
        }
        
        let fullSuccess: VSuccessBlock =  { (operaiton: NSOperation?, result: AnyObject?, resultObjects: [AnyObject]) -> Void in
            success?( results: resultObjects as? [GIFSearchResult] ?? [] )
        }
        let fullFail: VFailBlock =  { (operation: NSOperation?, error: NSError? ) -> Void in
            failure?( error: error, cancelled: operation?.cancelled ?? false )
        }
        
        return self.paginationManager.loadFilter( filter, withPageType: pageType, successBlock: fullSuccess, failBlock: fullFail )
    }
    
    func filterForKeywords( keywordList: String ) -> VAbstractFilter {
        
        let page = VPaginationManagerPageNumberMacro
        let perPage = VPaginationManagerItemsPerPageMacro
        let path = "/api/image/gif_search/\(keywordList)/\(page)/\(perPage)"
        let context = self.managedObjectStore.persistentStoreManagedObjectContext
        return self.paginationManager.filterForPath( path, entityName: VAbstractFilter.entityName(), managedObjectContext: context )
    }
}