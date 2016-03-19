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
