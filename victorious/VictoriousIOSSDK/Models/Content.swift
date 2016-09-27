//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics
import Foundation

public struct Content: Equatable {
    public typealias ID = String
    
    // MARK: - Identity
    
    /// The content's ID. Will be nil if the content was created from a VIP chat message, which doesn't have an ID.
    public var id: ID?
    
    // MARK: - Author
    
    /// The author of this content.
    public var author: UserModel?
    
    // MARK: - Content
    
    /// The type of content that is contained by this model.
    public var type: ContentType
    
    /// The content's text or media caption.
    public var text: String?
    
    /// A list of images of different sizes that can be used as the content's preview.
    public var previewImages: [ImageAssetModel]
    
    /// A list of assets of different sizes that are contained by this content.
    public var assets: [ContentMediaAssetModel]
    
    /// A URL that this content links to, if any.
    public var linkedURL: NSURL?
    
    /// Whether this content is only accessible for VIP users.
    public var isVIPOnly: Bool
    
    // MARK: - Tagging
    
    /// The hashtags contained by the content.
    public var hashtags: [Hashtag]
    
    /// A mapping of usernames to corresponding deep link URLs for users who are tagged in the content's `text`.
    ///
    /// When rendering the `text`, all occurrences of that username that are preceded by an @ character within the text
    /// should be rendered as a tappable link to the corresponding deep link URL.
    ///
    public var userTags: [String: NSURL]
    
    // MARK: - Liking
    
    /// The number of likes that this piece of content has received.
    public var likeCount: Int?
    
    /// Whether the server has reported that this content was liked by the current user.
    ///
    /// The server updates content like state asynchronously, so it may not always report the most up-to-date value.
    /// Using the `isLikedByCurrentUser` property is preferred because it will factor in our optimistic cache data as
    /// well.
    ///
    public var isRemotelyLikedByCurrentUser: Bool
    
    // MARK: - Timestamps
    
    /// The time that this content was created by the user and submitted to the server.
    ///
    /// This can be used to match locally-created content to content returned from the server. If content was created
    /// by the same user and has the same `postedAt` date, then it is guaranteed to be the same content.
    ///
    /// Will be nil for chat messages.
    ///
    public var postedAt: Timestamp?
    
    /// The time that this content was created on the server at.
    public var createdAt: Timestamp
    
    /// The timestamp value to use for pagination purposes.
    public var paginationTimestamp: Timestamp
    
    // MARK: - Sharing
    
    /// The URL that should be used to link to this content when sharing outside of the app.
    public var shareURL: NSURL?
    
    // MARK: - Tracking
    
    /// The content's tracking information.
    public var tracking: TrackingModel?
    
    // MARK: - Syncing
    
    /// The time this piece of video content started in our device time. It may be used in order to sync video content
    /// between sessions.
    public var localStartTime: NSDate?
    
    // MARK: - Initializing
    
    public init?(json viewedContentJSON: JSON) {
        let json = viewedContentJSON["content"]
        
        guard
            let id = json["id"].string,
            let typeString = json["type"].string,
            let type = ContentType(rawValue: typeString),
            let previewType = json["preview"]["type"].string
        else {
            Log.warning("Required field missing in content json -> \(viewedContentJSON)")
            return nil
        }
        
        let sourceType = json[typeString]["type"].string ?? typeString
        
        self.id = id
        self.author = User(json: viewedContentJSON["author"])
        self.type = type
        
        if type == .text {
            text = json[typeString]["data"].string
        }
        else {
            text = json["title"].string
        }
        
        previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        
        switch type {
            case .image:
                assets = [ContentMediaAsset(contentType: type, sourceType: sourceType, json: json[typeString])].flatMap { $0 }
            case .gif, .video:
                assets = (json[typeString][sourceType].array ?? []).flatMap { ContentMediaAsset(contentType: type, sourceType: sourceType, json: $0) }
            case .text, .link:
                assets = []
            case .sticker:
                assets = [ContentMediaAsset(contentType: type, sourceType: sourceType, json: json[typeString])].flatMap { $0 }

        }
        
        linkedURL = NSURL(string: json[typeString]["data"].stringValue)
        isVIPOnly = json["is_vip"].bool ?? false
        hashtags = []
        
        userTags = [:]
        
        for (username, urlJSON) in json["user_tags"].dictionary ?? [:] {
            guard let urlString = urlJSON.string, let url = NSURL(string: urlString) else {
                continue
            }
            
            userTags[username] = url
        }
        
        likeCount = viewedContentJSON["total_engagements"]["likes"].int
        isRemotelyLikedByCurrentUser = viewedContentJSON["viewer_engagements"]["is_liking"].bool ?? false
        postedAt = Timestamp(apiString: json["posted_at"].stringValue)
        createdAt = Timestamp(apiString: json["released_at"].stringValue) ?? Timestamp()
        paginationTimestamp = Timestamp(apiString: viewedContentJSON["pagination_timestamp"].stringValue) ?? Timestamp()
        shareURL = json["share_url"].URL
        tracking = Tracking(json: json["tracking"])
    }
    
    public init?(chatMessageJSON json: JSON, serverTime: Timestamp) {
        guard let user = User(json: json["user"]) else {
            return nil
        }
        
        id = nil
        author = user
        assets = [ContentMediaAsset(forumJSON: json["asset"])].flatMap { $0 }
        type = assets.first?.contentType ?? .text
        text = json["text"].string
        previewImages = []
        linkedURL = nil
        isVIPOnly = false
        hashtags = []
        userTags = [:]
        isRemotelyLikedByCurrentUser = false
        postedAt = nil
        createdAt = serverTime
        paginationTimestamp = serverTime
        shareURL = nil
        tracking = nil //Tracking is not returned on chat messages
        
        // Either one of these types are required to be counted as a chat message.
        guard text != nil || assets.count > 0 else {
            return nil
        }
    }
    
    public init?(lightweightJSON json: JSON) {
        guard
            let id = json["id"].string,
            let typeString = json["type"].string,
            let type = ContentType(rawValue: typeString),
            let previewType = json["preview"]["type"].string
        else {
            Log.warning("Required field missing in content json -> \(json)")
            return nil
        }
        self.id = id
        self.type = type
        
        isVIPOnly = json["is_vip"].bool ?? false
        paginationTimestamp = Timestamp(apiString: json["pagination_timestamp"].stringValue) ?? Timestamp()
        previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        tracking = Tracking(json: json["tracking"] )
        linkedURL = NSURL(string: json[typeString]["data"].stringValue)

        author = nil
        likeCount = nil
        postedAt = nil
        createdAt = Timestamp()
        text = nil
        hashtags = []
        shareURL = nil
        assets  = []
        userTags = [:]
        isRemotelyLikedByCurrentUser = false
    }
    
    public init(
        author: UserModel? = nil,
        id: String? = nil,
        createdAt: Timestamp = Timestamp(),
        postedAt: Timestamp = Timestamp(),
        paginationTimestamp: Timestamp = Timestamp(),
        type: ContentType = .text,
        text: String? = nil,
        assets: [ContentMediaAssetModel] = [],
        previewImages: [ImageAssetModel] = [],
        userTags: [String: NSURL] = [:],
        localStartTime: NSDate? = nil,
        isVIPOnly: Bool = false
    ) {
        self.id = id
        self.author = author
        self.type = type
        self.text = text
        self.previewImages = previewImages
        self.assets = assets
        self.linkedURL = nil
        self.isVIPOnly = isVIPOnly
        self.hashtags = []
        self.userTags = userTags
        self.isRemotelyLikedByCurrentUser = false
        self.postedAt = postedAt
        self.createdAt = createdAt
        self.paginationTimestamp = paginationTimestamp
        self.shareURL = nil
        self.tracking = nil
        self.localStartTime = localStartTime
    }
}

private var hiddenContentIDs = Set<Content.ID>()
private var likedContentHistory: [Content.ID: Bool] = [:]

extension Content: PreviewImageContainer, DictionaryConvertible {
    
    // MARK: - Hiding content
    
    public static func hideContent(withID id: Content.ID) {
        hiddenContentIDs.insert(id)
    }
    
    public static func contentIsHidden(withID id: Content.ID) -> Bool {
        return hiddenContentIDs.contains(id)
    }
    
    // MARK: - Liking content
    
    public static func likeContent(withID id: Content.ID) {
        likedContentHistory[id] = true
    }
    
    public static func unlikeContent(withID id: Content.ID) {
        likedContentHistory[id] = false
    }
    
    public var isLikedByCurrentUser: Bool {
        if let id = id, let record = likedContentHistory[id] {
            return record
        }
        else {
            return isRemotelyLikedByCurrentUser
        }
    }
    
    public var currentUserLikeCount: Int {
        if isRemotelyLikedByCurrentUser && !isLikedByCurrentUser && likeCount > 0 {
            return -1
        }
        
        if !isRemotelyLikedByCurrentUser && isLikedByCurrentUser {
            return 1
        }
        
        return 0
    }
}

extension Content {
    
    // MARK: - DictionaryConvertible
    
    public var rootKey: String {
        return "chat"
    }
    
    public var rootTypeKey: String? {
        return "type"
    }
    
    public var rootTypeValue: String? {
        return "CHAT"
    }
    
    public func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["type"] = "TEXT"
        dictionary["text"] = text
        
        if let assetURL = assets.first?.url  {
            let media: [String: String] = [
                "type": type.rawValue.uppercaseString,
                "url": assetURL.absoluteString ?? ""
            ]
            dictionary["media"] = media
        }
        
        return dictionary
    }
    
    public var seekAheadTime: NSTimeInterval? {
        guard let localStartTime = localStartTime else {
            return nil
        }
        
        return NSDate().timeIntervalSinceDate(localStartTime)
    }
}

public func ==(lhs: Content, rhs: Content) -> Bool {
    guard lhs.id != nil && rhs.id != nil else {
        return false
    }
    
    return lhs.id == rhs.id
}
