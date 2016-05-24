//
//  ContentMediaAssetModel.swift
//  victorious
//
//  Created by Tian Lan on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ContentMediaAssetModel {
    
    /// Returns either the youtube ID or the remote URL that links to the content
    var uniqueID: String { get }
    
    /// Returns "youtube", "giphy", or nil
    var source: String? { get }
}
