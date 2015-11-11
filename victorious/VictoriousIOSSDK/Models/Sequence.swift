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
    public let remoteID: String
    public let headline: String?
    public let name: String
    public let category: Category
    public let commentCount: Int
    public let gifCount: Int
    public let hasReposted: Bool
    public let isComplete: Bool
    public let isLikedByMainUser: Bool
    public let isRemix: Bool
    public let isRepost: Bool
    public let likeCount: Int
    public let memeCount: Int
    public let nameEmbeddedInContent: Bool
    public let parentUserID: Int64?
    public let permissionsMask: Int
    public let previewData: AnyObject?
    public let previewType: AssetType?
    public let releasedAt: NSDate?
    public let repostCount: Int
    public let sequenceDescription: String?
    public let adBreaks: [AdBreak]
    public let comments: [Comment]
    public let endCard: EndCard?
    public let likers: [User]
    public let nodes: [Node]
    public let parentUser: User?
    public let tracking: Tracking?
    public let user: User
    public let voteResults: [VoteResult]
    public let recentComments: [Comment]
    public let isGifStyle: Bool
    public let trendingTopicName: String?
    
    // MARK: - StreamItemType
    
    public let previewImagesObject: AnyObject?
    public let previewTextPostAsset: String?
    public let previewImageAssets: [ImageAsset]
}

extension Sequence {
    public init?(json: JSON) {
        
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        
        // MARK: - Required data
        
        guard let category      = Category(rawValue: json["category"].string ?? ""),
            let remoteID        = json["id"].string,
            let user            = User(json: json["user"]),
            let releasedAt      = dateFormatter.dateFromString(json["released_at"].string ?? "") else {
            return nil
        }
        self.category           = category
        self.remoteID           = remoteID
        self.releasedAt         = releasedAt
        self.user               = user
    
        // MARK: - Optional data
        
        headline                = json["entry_label"].string
        name                    = json["name"].string ?? ""
        sequenceDescription     = json["description"].string ?? ""
        isComplete              = json["is_complete"].bool ?? false
        isRemix                 = json["is_remix"].bool ?? false
        isRepost                = json["is_repost"].bool ?? false
        isLikedByMainUser       = json["am_liking"].bool ?? false
        permissionsMask         = json["permissions"].int ?? 0
        nameEmbeddedInContent   = json["name_embedded_in_content"].bool ?? false
        commentCount            = json["sequence_counts"]["comments"].int ?? 0
        gifCount                = json["sequence_counts"]["gifs"].int ?? 0
        memeCount               = json["sequence_counts"]["memes"].int ?? 0
        repostCount             = json["sequence_counts"]["reposts"].int ?? 0
        likeCount               = json["sequence_counts"]["likes"].int ?? 0
        previewType             = AssetType(rawValue:json["preview"]["type"].string ?? "")
        previewData             = json["preview.data"].object
        hasReposted             = json["has_reposted"].bool ?? false
        isGifStyle              = json["is_gif_style"].bool ?? false
        trendingTopicName       = json["trending_topic_name"].string
        parentUserID            = json["parent_user"].int64
        adBreaks                = (json["ad_breaks"].array ?? []).flatMap { AdBreak(json: $0) }
        comments                = (json["comments"].array ?? []).flatMap { Comment(json: $0) }
        endCard                 = EndCard(json: json["endcard"])
        likers                  = (json["comments"].array ?? []).flatMap { User(json: $0) }
        nodes                   = (json["nodes"].array ?? []).flatMap { Node(json: $0) }
        parentUser              = User(json: json["parent_user"])
        tracking                = Tracking(json: json["tracking"])
        voteResults             = (json["sequence_counts"]["votetypes"].array ?? []).flatMap { VoteResult(json: $0) }
        recentComments          = (json["recent_comments"].array ?? []).flatMap { Comment(json: $0) }
        
        // MARK: - StreamItemType
        
        previewImagesObject     = json["preview_image"].object
        previewTextPostAsset    = json["preview"].string
        previewImageAssets      = (json["preview"]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
    }
}
