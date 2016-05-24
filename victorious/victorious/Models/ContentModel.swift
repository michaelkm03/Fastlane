//
//  ContentModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ContentModel {
    var id: String { get }
    var title: String? { get }
    var tags: [Hashtag]? { get }
    var shareURL: NSURL? { get }
    var releasedAt: NSDate { get }
    var previewImages: [ImageAssetModel]? { get }
    var contentData: [ContentMediaAssetModel]? { get }
    var type: ContentType { get }
    var isVIP: Bool? { get }
    
    // Take the following property out later
    var stageContent: StageContent? { get }
}
