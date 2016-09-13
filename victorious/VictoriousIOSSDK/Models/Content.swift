//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics
import Foundation

/// Conformers are models that store information about piece of content in the app
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
public protocol ContentModel: PreviewImageContainer, DictionaryConvertible {
    var type: ContentType { get }
    
    /// `id` is optional because live chat messages don't have IDs
    var id: Content.ID? { get }
    var isRemotelyLikedByCurrentUser: Bool { get }
    var text: String? { get }
    var hashtags: [Hashtag] { get }
    var shareURL: NSURL? { get }
    var linkedURL: NSURL? { get }
    var author: UserModel { get }
    
    /// The time that the user created the content locally.
    ///
    /// This can be used to match locally-created content to content returned from the server. If content was created
    /// by the same user and has the same `postedAt` date, then it is guaranteed to be the same content.
    ///
    /// Will be nil for chat messages.
    ///
    var postedAt: Timestamp? { get }
    
    /// The time that the content was created on the server.
    var createdAt: Timestamp { get }
    
    /// The timestamp that pagination logic should be performed with.
    var paginationTimestamp: Timestamp { get }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool { get }
    
    /// An array of preview images for the content.
    var previewImages: [ImageAssetModel] { get }
    
    /// An array of media assets for the content, could be any media type
    var assets: [ContentMediaAssetModel] { get }
    
    /// The time this piece of video content started in our device time.
    /// It may be used in order to sync video content between sessions.
    var localStartTime: NSDate? { get set }
    
    /// Keys correspond to an array of string-represented tracking urls
    var tracking: TrackingModel? { get }
}

public func ==(lhs: ContentModel, rhs: ContentModel) -> Bool {
    guard lhs.id != nil && rhs.id != nil else {
        return false
    }
    
    return lhs.id == rhs.id
}

public func !=(lhs: ContentModel, rhs: ContentModel) -> Bool {
    return !(lhs == rhs)
}

extension ContentModel {
    
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
            dictionary["media"] = [
                "type": type.rawValue.uppercaseString,
                "url": assetURL.absoluteString
            ]
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

private var hiddenContentIDs = Set<Content.ID>()
private var likedContentHistory: [Content.ID: Bool] = [:]

extension ContentModel {
    
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
}

public class Content: ContentModel {
    public typealias ID = String
    
    // MARK: - Identity
    
    /// The content's ID. Will be nil if the content was created from a VIP chat message, which doesn't have an ID.
    public let id: ID?
    
    // MARK: - Author
    
    /// The author of this content.
    public let author: UserModel
    
    // MARK: - Content
    
    /// The type of content that is contained by this model.
    public let type: ContentType
    
    /// The content's text or media caption.
    public let text: String?
    
    /// A list of images of different sizes that can be used as the content's preview.
    public let previewImages: [ImageAssetModel]
    
    /// A list of assets of different sizes that are contained by this content.
    public let assets: [ContentMediaAssetModel]
    
    /// A URL that this content links to, if any.
    public let linkedURL: NSURL?
    
    /// Whether this content is only accessible for VIP users.
    public let isVIPOnly: Bool
    
    // MARK: - Tagging
    
    /// The hashtags contained by the content.
    public let hashtags: [Hashtag]
    
    /// A mapping of usernames to corresponding deep link URLs for users who are tagged in the content's `text`.
    ///
    /// When rendering the `text`, all occurrences of that username that are preceded by an @ character within the text
    /// should be rendered as a tappable link to the corresponding deep link URL.
    ///
    public let userTags: [String: NSURL]
    
    // MARK: - Liking
    
    /// Whether the server has reported that this content was liked by the current user.
    ///
    /// The server updates content like state asynchronously, so it may not always report the most up-to-date value.
    /// Using the `isLikedByCurrentUser` property is preferred because it will factor in our optimistic cache data as
    /// well.
    ///
    public let isRemotelyLikedByCurrentUser: Bool
    
    // MARK: - Timestamps
    
    /// The time that this content was created by the user and submitted to the server.
    ///
    /// This can be used to match locally-created content to content returned from the server. If content was created
    /// by the same user and has the same `postedAt` date, then it is guaranteed to be the same content.
    ///
    /// Will be nil for chat messages.
    ///
    public let postedAt: Timestamp?
    
    /// The time that this content was created on the server at.
    public let createdAt: Timestamp
    
    /// The timestamp value to use for pagination purposes.
    public let paginationTimestamp: Timestamp
    
    // MARK: - Sharing
    
    /// The URL that should be used to link to this content when sharing outside of the app.
    public let shareURL: NSURL?
    
    // MARK: - Tracking
    
    /// The content's tracking information.
    public let tracking: TrackingModel?
    
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
            let previewType = json["preview"]["type"].string,
            let author = User(json: viewedContentJSON["author"])
        else {
            NSLog("Required field missing in content json -> \(viewedContentJSON)")
            return nil
        }
        
        let sourceType = json[typeString]["type"].string ?? typeString
        
        self.id = id
        self.author = author
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
        }
        
        linkedURL = NSURL(string: json[typeString]["data"].stringValue)
        isVIPOnly = json["is_vip"].bool ?? false
        hashtags = []
        
        // TODO: Get real data.
        userTags = [
            "jarod": NSURL(string: "vthisapp://profile/7256")!
        ]
        
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
    
    public init(
        author: UserModel,
        id: String? = nil,
        createdAt: Timestamp = Timestamp(),
        postedAt: Timestamp = Timestamp(),
        paginationTimestamp: Timestamp = Timestamp(),
        type: ContentType = .text,
        text: String? = nil,
        assets: [ContentMediaAssetModel] = [],
        previewImages: [ImageAssetModel] = [],
        localStartTime: NSDate? = nil
    ) {
        self.id = id
        self.author = author
        self.type = type
        self.text = text
        self.previewImages = previewImages
        self.assets = assets
        self.linkedURL = nil
        self.isVIPOnly = false
        self.hashtags = []
        self.userTags = [:]
        self.isRemotelyLikedByCurrentUser = false
        self.postedAt = postedAt
        self.createdAt = createdAt
        self.paginationTimestamp = paginationTimestamp
        self.shareURL = nil
        self.tracking = nil
        self.localStartTime = localStartTime
    }
}
