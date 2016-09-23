//
//  AssetSearchOptions.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Encapsulates input parameters for fetching assets from a remote source
public enum AssetSearchOptions {
    case Search(term: String, url: String)
    case Trending(url: String)
}
