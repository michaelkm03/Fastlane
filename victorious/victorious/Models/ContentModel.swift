//
//  ContentModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers are models that store information about piece of content in the app
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
protocol ContentModel {
    var releasedAt: NSDate { get }
    var type: ContentType { get }
    
    var id: String? { get }
    var text: String? { get }
    var hashtags: [Hashtag] { get }
    var shareURL: NSURL? { get }
    var author: UserModel? { get }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool? { get }
    
    /// An array of preview images for the content.
    var previewImages: [ImageAssetModel] { get }
    
    /// An array of media assets for the content, could be any media type
    var assets: [ContentMediaAssetModel] { get }
    
    // Future: Take the following property out
    var stageContent: StageContent? { get }
}
