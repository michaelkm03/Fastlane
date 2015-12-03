//
//  PageableOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

protocol PageableOperation {
    var nextPageOperation: Self? { get }
    var previousPageOperation: Self? { get }
}

extension PageableOperation {
    
    func adjacentOperation(forPageType pageType: VPageType) -> Self?{
        switch pageType {
        case .First:
            return nil
        case .Next:
            return self.nextPageOperation
        case .Previous:
            return self.previousPageOperation
        }
    }
}


