//
//  VContent.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData
import VictoriousIOSSDK

class VContent: NSManagedObject, ContentModel, PaginatableItem {
    @NSManaged var v_createdAt: Int64
    @NSManaged var v_postedAt: Int64
    @NSManaged var v_paginationTimestamp: Int64
    @NSManaged var v_remoteID: String
    @NSManaged var v_shareURL: String?
    @NSManaged var v_linkedURL: String?
    @NSManaged var v_status: String?
    @NSManaged var v_text: String?
    @NSManaged var v_type: String
    @NSManaged var v_isVIPOnly: NSNumber?
    @NSManaged var v_isRemotelyLikedByCurrentUser: NSNumber?
    @NSManaged var v_likeCount: NSNumber?
    @NSManaged var v_contentMediaAssets: Set<VContentMediaAsset>
    @NSManaged var v_author: VUser
    @NSManaged var v_contentPreviewAssets: Set<VImageAsset>
    @NSManaged var v_tracking: VTracking?
    
    // MARK: - ContentModel
    
    var tracking: TrackingModel? {
        return v_tracking
    }
    
    var createdAt: Timestamp {
        return Timestamp(value: v_createdAt) ?? Timestamp()
    }
    
    var postedAt: Timestamp? {
        return Timestamp(value: v_postedAt)
    }
    
    var paginationTimestamp: Timestamp {
        return Timestamp(value: v_paginationTimestamp) ?? Timestamp()
    }
    
    var text: String? {
        return v_text
    }
    
    var type: ContentType {
        switch v_type {
            case "image": return .image
            case "video": return .video
            case "gif": return .gif
            case "text": return .text
            case "link": return .link
            
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
    
    var linkedURL: NSURL? {
        guard let linkedURL = v_linkedURL else {
            return nil
        }
        return NSURL(string: linkedURL)
    }
    
    var author: UserModel {
        return v_author
    }
    
    var isRemotelyLikedByCurrentUser: Bool {
        return v_isRemotelyLikedByCurrentUser == true
    }

    var likeCount: Int? {
        guard let v_likeCount = v_likeCount else {
            return nil
        }
        return Int(v_likeCount)
    }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool {
        return v_isVIPOnly == true
    }
    
    /// An array of preview images for the content.
    var previewImages: [ImageAssetModel] {
        return v_contentPreviewAssets.map { $0 }
    }
    
    /// An array of media assets for the content, could be any media type
    var assets: [ContentMediaAssetModel] {
        return v_contentMediaAssets.map { $0 }
    }
    
    /// VContent does not provide localStartTime
    var localStartTime: NSDate? {
        get {
            return nil
        }
        
        set {
            return
        }
    }
}

extension Content: PaginatableItem {}
