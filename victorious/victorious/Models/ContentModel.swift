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
protocol ContentModel: PreviewImageContainer, PaginatableItem {
    var createdAt: NSDate { get }
    var type: ContentType { get }
    
    var id: String? { get }
    var isLikedByCurrentUser: Bool { get }
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
    
    /// seekAheadTime to keep videos in sync for videos on VIP stage
    var seekAheadTime: NSTimeInterval? { get set }
    
    func toSDKContent() -> Content
}

extension ContentModel {
    // MARK: - UI strings
    
    var timeLabel: String {
        return createdAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
    
    // MARK: - Assets
    
    var aspectRatio: CGFloat {
        return previewImageModels.first?.mediaMetaData.size?.aspectRatio ?? 0.0
    }
}

extension VContent: ContentModel {
    var createdAt: NSDate {
        return v_createdAt
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
            case "link":
                return .link
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
    
    var isLikedByCurrentUser: Bool {
        return v_isLikedByCurrentUser == true
    }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool {
        return v_isVIPOnly == true
    }
    
    /// An array of preview images for the content.
    var previewImageModels: [ImageAssetModel] {
        return v_contentPreviewAssets.map { $0 }
    }
    
    /// An array of media assets for the content, could be any media type
    var assetModels: [ContentMediaAssetModel] {
        return v_contentMediaAssets.map { $0 }
    }
    
    /// VContent does not provide seekAheadTime
    var seekAheadTime: NSTimeInterval? {
        get {
            return nil
        }
        
        set {
            return
        }
    }
    
    func toSDKContent() -> Content {
        return Content(
            id: id,
            createdAt: createdAt,
            type: type,
            text: text,
            assets: assetModels.map { $0.toSDKAsset() },
            previewImages: previewImageModels.map { $0.toSDKImageAsset() },
            author: authorModel.toSDKUser()
        )
    }
}

extension Content: ContentModel {
    
    var authorModel: UserModel {
        return author
    }
        
    var previewImageModels: [ImageAssetModel] {
        return previewImages?.map { $0 } ?? []
    }
    
    var assetModels: [ContentMediaAssetModel] {
        return assets.map { $0 as ContentMediaAssetModel }
    }

    func toSDKContent() -> Content {
        return self
    }
}
