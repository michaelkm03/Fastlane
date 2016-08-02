//
//  PaginatedLoadingType.swift
//  victorious
//
//  Created by Jarod Long on 8/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// The different ways that paginated items can be loaded.
public enum PaginatedLoadingType {
    /// Loads the newest page of items, replacing any existing items.
    case refresh
    
    /// Loads newer items, prepending them to the list.
    case newer
    
    /// Loads older items, appending them to the list.
    case older
}
