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
    case search(term: String, url: String)
    case trending(url: String)
}
