//
//  AssetSearchOptions.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public enum AssetSearchOptions {
    case Search(term: String, url: String)
    case Trending(url: String)
}
