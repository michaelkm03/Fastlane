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

extension VPageType {
    
    func operationFromOperation<T: PageableOperation>( operation: T? ) -> T? {
        switch self {
        case .First:
            return nil
        case .Next:
            return operation?.nextPageOperation
        case .Previous:
            return operation?.previousPageOperation
        }
    }
}


