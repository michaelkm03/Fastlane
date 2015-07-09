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
    
    func searchForGIF( keywords: [String], success:(([GIFSearchResult])->())?, failure:((NSError?)->())? ) -> RKManagedObjectRequestOperation {
        
        let keywordList: String = join( ",", keywords )
        let escapedKeywordList = keywordList.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.alphanumericCharacterSet() )
        // FIXME: Force unwrap, wish there was a guard!
        let abstractFilter = self.filterForKeywords( escapedKeywordList! )
        
        let fullSuccess: VSuccessBlock =  { (operaiton: NSOperation?, result: AnyObject?, resultObjects: [AnyObject]) -> Void in
            success?( resultObjects as? [GIFSearchResult] ?? [] )
        }
        
        let fullFail: VFailBlock =  { (operation: NSOperation?, error: NSError? ) -> Void in
            failure?( error )
        }
        
        return self.paginationManager.loadFilter( abstractFilter, withPageType: VPageType.First, successBlock: fullSuccess, failBlock: fullFail )
    }
    
    func filterForKeywords( keywordList: String ) -> VAbstractFilter {
        let page = VPaginationManagerPageNumberMacro
        let perPage = VPaginationManagerItemsPerPageMacro
        let path = "/api/image/gif_search/\(keywordList)/\(page)/\(perPage)"
        let context = self.managedObjectStore.persistentStoreManagedObjectContext
        return self.paginationManager.filterForPath( path, entityName: VAbstractFilter.entityName(), managedObjectContext: context )
    }
}