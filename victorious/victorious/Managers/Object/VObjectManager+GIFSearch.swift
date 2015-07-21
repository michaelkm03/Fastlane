//
//  VObjectManager+GIFSearch.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

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
    typealias GIFSearchFailure = (error: NSError?, isLastPage: Bool) -> ()
    
    /// Fetches GIF search results for the provided keyword lsit
    ///
    /// :param: keywords Array of string keywords used to search for GIFs
    /// :param: pageType An enum value indicating which page to load in a series of paginated requests
    /// :param: success Closure to be called when request receives a non-error response
    /// :param: failure Closure to be called when request receives an error response
    func searchForGIF( keywords: [String], pageType:VPageType, success:GIFSearchSuccess?, failure:GIFSearchFailure? ) -> RKManagedObjectRequestOperation? {
        
        let keywordList: String = join( ",", keywords )
        let charSet = NSCharacterSet.alphanumericCharacterSet()
        let escapedKeywordList = keywordList.stringByAddingPercentEncodingWithAllowedCharacters( charSet )!
        
        var filter = self.filterForKeywords( escapedKeywordList )
        if !filter.canLoadPageType( pageType ) {
            failure?( error: nil, isLastPage: true )
            return nil
        }
        
        let fullSuccess: VSuccessBlock =  { (operaiton: NSOperation?, result: AnyObject?, resultObjects: [AnyObject]) -> Void in
            success?( results: resultObjects as? [GIFSearchResult] ?? [], isLastPage: filter.isLastPage )
        }
        let fullFail: VFailBlock =  { (operation: NSOperation?, error: NSError? ) -> Void in
            failure?( error: error, isLastPage: false )
        }
        
        return self.paginationManager.loadFilter( filter, withPageType: pageType, successBlock: fullSuccess, failBlock: fullFail )
    }
    
    /// Fetches trending GIF search results to show as default content
    ///
    /// :param: pageType An enum value indicating which page to load in a series of paginated requests
    /// :param: success Closure to be called when request receives a non-error response
    /// :param: failure Closure to be called when request receives an error response
    func loadTrendingGIFs( pageType:VPageType, success:GIFSearchSuccess?, failure:GIFSearchFailure? ) -> RKManagedObjectRequestOperation? {
        
        var filter = self.filterForTrending()
        if !filter.canLoadPageType( pageType ) {
            failure?( error: nil, isLastPage: true )
            return nil
        }
        
        let fullSuccess: VSuccessBlock =  { (operaiton: NSOperation?, result: AnyObject?, resultObjects: [AnyObject]) -> Void in
            success?( results: resultObjects as? [GIFSearchResult] ?? [], isLastPage: filter.isLastPage )
        }
        let fullFail: VFailBlock =  { (operation: NSOperation?, error: NSError? ) -> Void in
            failure?( error: error, isLastPage: false )
        }
        
        return self.paginationManager.loadFilter( filter, withPageType: pageType, successBlock: fullSuccess, failBlock: fullFail )
    }
    
    // MARK: - Private helpers
    
    private func filterForTrending() -> VAbstractFilter {
        let page = VPaginationManagerPageNumberMacro
        let perPage = VPaginationManagerItemsPerPageMacro
        let path = "/api/image/trending_gifs/\(page)/\(perPage)"
        let context = self.managedObjectStore.persistentStoreManagedObjectContext
        return self.paginationManager.filterForPath( path, entityName: VAbstractFilter.entityName(), managedObjectContext: context )
    }
    
    private func filterForKeywords( keywordList: String ) -> VAbstractFilter {
        let page = VPaginationManagerPageNumberMacro
        let perPage = VPaginationManagerItemsPerPageMacro
        let path = "/api/image/gif_search/\(keywordList)/\(page)/\(perPage)"
        let context = self.managedObjectStore.persistentStoreManagedObjectContext
        return self.paginationManager.filterForPath( path, entityName: VAbstractFilter.entityName(), managedObjectContext: context )
    }
}