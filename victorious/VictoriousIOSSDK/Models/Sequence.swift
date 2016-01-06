//
// Sequence.swift
// victorious
//
// Created by Patrick Lynch on 11/5/15.
// Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Sequence: StreamItemType {
    public let sequenceID: String
    public let category: Category
    public let user: User
    public let headline: String?
    public let name: String?
    public let commentCount: Int?
    public let gifCount: Int?
    public let likeCount: Int?
    public let memeCount: Int?
    public let repostCount: Int?
    public let hasReposted: Bool?
    public let isComplete: Bool?
    public let isLikedByMainUser: Bool?
    public let isRemix: Bool?
    public let isRepost: Bool?
    public let nameEmbeddedInContent: Bool?
    public let parentUserID: Int?
    public let permissionsMask: Int?
    public let previewData: AnyObject?
    public let previewType: AssetType?
    public let sequenceDescription: String?
    public let adBreaks: [AdBreak]?
    public let comments: [Comment]?
    public let nodes: [Node]?
    public let parentUser: User?
    public let tracking: Tracking?
    public let recentComments: [Comment]?
    public let isGifStyle: Bool?
    public let trendingTopicName: String?
    
    // MARK: - StreamItemType
    
    public var streamItemID: String {
        return self.sequenceID
    }
    public let previewImagesObject: AnyObject?
    public let previewTextPostAsset: String?
    public let previewImageAssets: [ImageAsset]?  
    public let type: StreamContentType?
    public let subtype: StreamContentType?
    public let releasedAt: NSDate?
}

extension Sequence {
    public init?(json: JSON) {
        
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        
        // MARK: - Required data
        
        guard let category      = Category(rawValue: json["category"].stringValue),
            let sequenceID      = json["id"].string,
            let user            = User(json: json["user"]) else {
                return nil
        }
        self.category           = category
        self.sequenceID         = sequenceID
        self.user               = user
    
        // MARK: - Optional data
        
        releasedAt              = dateFormatter.dateFromString(json["released_at"].stringValue)
        type                    = StreamContentType(rawValue: json["type"].stringValue)
        subtype                 = StreamContentType(rawValue: json["subtype"].stringValue)
        headline                = json["entry_label"].string
        name                    = json["name"].string
        sequenceDescription     = json["description"].string
        isComplete              = json["is_complete"].bool
        isRemix                 = json["is_remix"].bool
        isRepost                = json["is_repost"].bool
        isLikedByMainUser       = json["am_liking"].bool
        permissionsMask         = json["permissions"].int
        nameEmbeddedInContent   = json["name_embedded_in_content"].bool
        commentCount            = json["sequence_counts"]["comments"].int
        gifCount                = json["sequence_counts"]["gifs"].int
        memeCount               = json["sequence_counts"]["memes"].int
        repostCount             = json["sequence_counts"]["reposts"].int
        likeCount               = json["sequence_counts"]["likes"].int
        previewType             = AssetType(rawValue:json["preview"]["type"].stringValue)
        previewData             = json["preview"]["data"].object
        hasReposted             = json["has_reposted"].bool
        isGifStyle              = json["is_gif_style"].bool
        trendingTopicName       = json["trending_topic_name"].string
        parentUserID            = json["parent_user"].int
        adBreaks                = json["ad_breaks"].array?.flatMap { AdBreak(json: $0) }
        comments                = json["comments"].array?.flatMap { Comment(json: $0) }
        nodes                   = json["nodes"].array?.flatMap { Node(json: $0) }
        parentUser              = User(json: json["parent_user"])
        tracking                = Tracking(json: json["tracking"])
        recentComments          = json["recent_comments"].array?.flatMap { Comment(json: $0) }
        
        // MARK: - StreamItemType
        
        previewImagesObject     = json["preview_image"].object
        previewTextPostAsset    = json["preview"].string
        previewImageAssets      = (json["preview"]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
    }
}
