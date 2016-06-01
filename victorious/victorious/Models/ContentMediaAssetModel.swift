//
//  ContentMediaAssetModel.swift
//  victorious
//
//  Created by Tian Lan on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers are models that store information about content media asset.
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
protocol ContentMediaAssetModel {
    
    /// Returns either the youtube ID or the remote URL that links to the content
    var resourceID: String { get }
    
    /// Returns where the video is hosted remotely
    var videoSource: ContentVideoAssetSource? { get }
    
    /// The asset's content type.
    var contentType: ContentType { get }
    
    /// The URL to the asset's content.
    var url: NSURL? { get }
    
    func toSDKAsset() -> ContentMediaAsset
}

/// The source of where the video is hosted.
/// - note: We currently only need to differenciate Youtube videos from other videos.
/// (Giphy is indifferent from other videos as of now.)
enum ContentVideoAssetSource {
    case youtube
    case video
}

extension VContentMediaAsset: ContentMediaAssetModel {
    var resourceID: String {
        return v_uniqueID
    }
    
    var videoSource: ContentVideoAssetSource? {
        guard let source = v_source else {
            return nil
        }
        
        switch source {
        case "youtube":
            return .youtube
        case "video", "giphy":
            return .video
        default:
            return nil
        }
    }
    
    var contentType: ContentType {
        switch v_source ?? "" {
        case "youtube", "video":
            return .video
        case "gif":
            return .gif
        case "image":
            return .image
        default:
            return .image
        }
    }
    
    var url: NSURL? {
        return NSURL(v_string: v_remoteSource)
    }
    
    func toSDKAsset() -> ContentMediaAsset {
        switch v_source ?? "" {
        case "video":
            return .video(url: url ?? NSURL(), source: v_source)
        case "youtube":
            return .youtube(remoteID: resourceID, source: v_source)
        case "gif":
            return .gif(url: url ?? NSURL(), source: v_source)
        case "image":
            return .image(url: url ?? NSURL())
        default:
            return .image(url: url ?? NSURL())
        }
    }
}

extension ContentMediaAsset: ContentMediaAssetModel {
    var resourceID: String {
        return uniqueID
    }
    
    var videoSource: ContentVideoAssetSource? {
        switch self {
        case .video(_, _), .gif(_, _):
            return .video
        case .youtube(_, _):
            return .youtube
        case .image(_):
            return nil
        }
    }
    
    func toSDKAsset() -> ContentMediaAsset {
        return self
    }
}
