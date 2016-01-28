//
//  NSIndexSet+Extensions.swift
//  victorious
//
//  Created by Patrick Lynch on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSIndexSet {
    
    var v_array: [Int] {
        var indexes:[Int] = [];
        self.enumerateIndexesUsingBlock { (index:Int, _) in
            indexes.append(index);
        }
        return indexes;
    }
    
    func v_indexPathsForSection( section: Int ) -> [NSIndexPath] {
        return v_array.map { NSIndexPath(forRow: $0, inSection: section) }
    }
}