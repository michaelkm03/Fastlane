//
//  MediaSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 1/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that provides all the required data to be rendered in
/// a search results view controller.
@objc protocol MediaSearchResult: class {
    var exportPreviewImage: UIImage? { get set }
    var exportMediaURL: URL? { get set }
    var sourceMediaURL: URL? { get }
    var thumbnailImageURL: URL? { get }
    var aspectRatio: CGFloat { get }
    var assetSize: CGSize { get }
    var remoteID: String? { get }
    var isVIP: Bool { get }
}
