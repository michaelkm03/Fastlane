//
//  HashtagBarCellPopulator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Populates a `HashtagBarCell`
struct HashtagBarCellPopulator {
    /// Populates a `HashtagBarCell` based on the provided tag
    static func populateCell(_ cell: HashtagBarCell, withTag tag: String) {
        
        cell.label.text = "#\(tag)"
        cell.label.numberOfLines = 1
    }
}
