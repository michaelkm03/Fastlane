//
//  ContentModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ContentModel {
    var releasedAt: NSDate { get }
    var type: ContentType { get }
    
    var id: String? { get }
    var text: String? { get }
    var hashtags: [Hashtag] { get }
    var shareURL: NSURL? { get }
    var isVIPOnly: Bool? { get }
    var author: UserModel? { get }
    
    var previewImages: [ImageAssetModel] { get }
    var assets: [ContentMediaAssetModel] { get }
    
    // Take the following property out later
    var stageContent: StageContent? { get }
}
