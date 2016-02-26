//
//  NumericPaginator+Predicate.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension NumericPaginator {
    
    var paginatorPredicate: NSPredicate {
        let arguments = [self.displayOrderRangeStart, self.displayOrderRangeEnd]
        return NSPredicate(format: "displayOrder >= %@ && displayOrder < %@", argumentArray: arguments)
    }
}

extension StandardPaginator {
    
    init?(displayOrder: Int, pageType: VPageType, itemsPerPage: Int) {
        
        guard displayOrder > 0 else {
            return nil
        }
        
        let pageNumber:Int
        switch pageType {
        case .First:
            return nil
        case .Next:
            pageNumber = Int( ceil( CGFloat(displayOrder) / CGFloat(itemsPerPage) ) )
        case .Previous:
            pageNumber = max(Int( floor( CGFloat(displayOrder) / CGFloat(itemsPerPage) ) ), 1)
        }
        self.init(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
}
