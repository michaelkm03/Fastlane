//
//  NSPredicate+Operators.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

func +(lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
    return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, rhs])
}
