//
//  VContentMediaAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData
import VictoriousIOSSDK

class VContentMediaAsset: NSManagedObject, ContentMediaAssetModel {
    /// External ID string of the remote content. Will be nil when remoteSource is not nil.
    @NSManaged var v_externalID: String?
    
    /// Remote URL string of the content. Will be nil when externalID is not nil.
    @NSManaged var v_remoteSource: String?
    
    @NSManaged var v_source: String?
    
    /// Identifier based on either the remoteSource or externalID as exactly one of those will be nil at any time.
    @NSManaged var v_remoteID: String
    
    @NSManaged var v_content: VContent
    @NSManaged var v_width: Float
    @NSManaged var v_height: Float
    
    // MARK: - ContentMediaAssetModel
    
    var resourceID: String {
        return v_remoteID
    }
    
    var source: String? {
        return v_source
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
                assertionFailure("Encountered unknown asset source '\(v_source)'.")
                return .image
        }
    }
    
    var url: NSURL? {
        return NSURL(v_string: v_remoteSource)
    }
    
    var externalID: String? {
        return v_externalID
    }
    
    var size: CGSize? {
        guard v_width != 0 && v_height != 0 else {
            return nil
        }
        let width = CGFloat(v_width)
        let height = CGFloat(v_height)
        
        return CGSize(width: width, height: height)
    }
}
