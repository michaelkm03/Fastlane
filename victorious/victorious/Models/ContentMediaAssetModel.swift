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
        return uniqueID
    }
    
    var videoSource: ContentVideoAssetSource? {
        guard let source = source else {
            return nil
        }
        
        if source == "youtube" {
            return .youtube
        }
        else {
            return .video
        }
    }
}

extension ContentMediaAsset: ContentMediaAssetModel {
    var resourceID: String {
        return uniqueID
    }
    
    var videoSource: ContentVideoAssetSource? {
        switch self {
        case .youtube(_,_):
            return .youtube
        default:
            return .video
        }
    }
}
