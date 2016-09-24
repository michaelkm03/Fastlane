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
    var exportMediaURL: NSURL? { get set }
    var sourceMediaURL: NSURL? { get }
    var thumbnailImageURL: NSURL? { get }
    var aspectRatio: CGFloat { get }
    var assetSize: CGSize { get }
    var remoteID: String? { get }
    var isVIP: Bool { get }
}
