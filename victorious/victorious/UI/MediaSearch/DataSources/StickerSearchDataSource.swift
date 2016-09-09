//
//  StickerSearchDataSource.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StickerSearchDataSource: PaginatedDataSource, MediaSearchDataSource {
    
    private(set) var options = MediaSearchOptions()
    
    override init() {
        options.showAttribution = true
        options.showPreview = true
    }
    
    func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: (NSError? -> ())? ) {
        
        //TODO: Look here!!
        let options = GIFSearchOptions.Search(term: "test", url: "test")
        self.loadPage( pageType,
            createOperation: {
                //Uncomment the line below for compile failure
                //let options = GIFSearchOptions.Search(term: "test", url: "test")
                return GIFSearchOperation(searchOptions: "test")
            },
            completion:{ (results, error, cancelled) in
                completion?( error )
            }
        )
    }
    
    var title: String {
        return NSLocalizedString( "Sticker Search", comment: "" )
    }
}