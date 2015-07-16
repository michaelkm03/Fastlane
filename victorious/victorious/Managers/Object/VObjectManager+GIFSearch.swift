//
//  VObjectManager+GIFSearch.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

private extension VAbstractFilter {
    var isLastPage: Bool {
        return self.currentPageNumber.integerValue == self.maxPageNumber.integerValue
    }
}

/// Provides methods for searching for GIFs through the backend
extension VObjectManager {
    
    /// Closure called when GIF search request succeeds
    ///
    /// :param: results An array of GIFSearchResult models found
    /// :param: isLastPage A bool indicating if there are are more results that can be loaded
    typealias GIFSearchSuccess = (results: [GIFSearchResult], isLastPage: Bool) -> ()
    
    /// Closure called when GIF search request fails
    ///
    /// :param: error An array of GIFSearchResult models found
    typealias GIFSearchFailure = (error: NSError?) -> ()
    
    func searchForGIF( keywords: [String], pageType:VPageType, success:GIFSearchSuccess?, failure:GIFSearchFailure? ) -> RKManagedObjectRequestOperation? {
        
        let keywordList: String = join( ",", keywords )
        let charSet = NSCharacterSet.alphanumericCharacterSet()
        let escapedKeywordList = keywordList.stringByAddingPercentEncodingWithAllowedCharacters( charSet )!
        
        var filter = self.filterForKeywords( escapedKeywordList )
        if !filter.canLoadPageType( pageType ) || self.paginationManager.isLoadingFilter( filter ) {
            return nil
        }
        
        let fullSuccess: VSuccessBlock =  { (operaiton: NSOperation?, result: AnyObject?, resultObjects: [AnyObject]) -> Void in
            success?( results: resultObjects as? [GIFSearchResult] ?? [], isLastPage: filter.isLastPage )
        }
        let fullFail: VFailBlock =  { (operation: NSOperation?, error: NSError? ) -> Void in
            failure?( error: error )
        }
        
        return self.paginationManager.loadFilter( filter, withPageType: pageType, successBlock: fullSuccess, failBlock: fullFail )
    }
    
    private func filterForKeywords( keywordList: String ) -> VAbstractFilter {
        let page = VPaginationManagerPageNumberMacro
        let perPage = VPaginationManagerItemsPerPageMacro
        let path = "/api/image/gif_search/\(keywordList)/\(page)/\(perPage)"
        let context = self.managedObjectStore.persistentStoreManagedObjectContext
        return self.paginationManager.filterForPath( path, entityName: VAbstractFilter.entityName(), managedObjectContext: context )
    }
}