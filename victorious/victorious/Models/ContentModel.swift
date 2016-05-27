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
protocol ContentModel: PreviewImageContainer {
    var releasedAt: NSDate { get }
    var type: ContentType { get }
    
    var id: String? { get }
    var text: String? { get }
    var hashtags: [Hashtag] { get }
    var shareURL: NSURL? { get }
    var authorModel: UserModel { get }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool { get }
    
    /// An array of preview images for the content.
    var previewImageModels: [ImageAssetModel] { get }
    
    /// An array of media assets for the content, could be any media type
    var assetModels: [ContentMediaAssetModel] { get }
    
    // Future: Take the following property out
    var stageContent: StageContent? { get }
}

extension ContentModel {
    // MARK: - UI strings
    
    var timeLabel: String {
        return releasedAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
    
    // MARK: - Assets
    
    var aspectRatio: CGFloat {
        guard let preview = previewImageModels.first,
            let aspectRatio = preview.mediaMetaData.size?.aspectRatio else {
            return 0
        }
        return aspectRatio
    }
}

extension VContent: ContentModel {
    var releasedAt: NSDate {
        return v_releasedAt
    }
    
    var text: String? {
        return v_text
    }
    
    var type: ContentType {
        switch v_type {
        case "image":
            return .image
        case "video":
            return .video
        case "gif":
            return .gif
        case "text":
            return .text
        default:
            assertionFailure("Should always have a valid type")
            return .text
        }
    }
    
    var id: String? {
        return v_remoteID
    }
    
    var hashtags: [Hashtag] {
        return []
    }
    
    var shareURL: NSURL? {
        guard let v_shareURL = v_shareURL else {
            return nil
        }
        return NSURL(string: v_shareURL)
    }
    
    var authorModel: UserModel {
        return v_author
    }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool {
        return v_isVIP == true
    }
    
    /// An array of preview images for the content.
    var previewImageModels: [ImageAssetModel] {
        guard let contentPreviewAssets = v_contentPreviewAssets else {
            return []
        }
        return contentPreviewAssets.flatMap({ $0 as? ImageAssetModel })
    }
    
    /// An array of media assets for the content, could be any media type
    var assetModels: [ContentMediaAssetModel] {
        guard let contentMediaAssets = v_contentMediaAssets else {
            return []
        }
        return contentMediaAssets.flatMap({ $0 as? ContentMediaAssetModel })
    }
    
    // Future: Take the following property out
    var stageContent: StageContent? {
        return nil
    }
}

extension Content: ContentModel {
    
    var authorModel: UserModel {
        return author
    }
        
    var previewImageModels: [ImageAssetModel] {
        guard let contentPreviewAssets = previewImages else {
            return []
        }
        return contentPreviewAssets.flatMap({ $0 as ImageAssetModel })
    }
    
    var isVIPOnly: Bool {
        return isVIP
    }
    
    var assetModels: [ContentMediaAssetModel] {
        return assets.map { $0 as ContentMediaAssetModel }
    }

}
