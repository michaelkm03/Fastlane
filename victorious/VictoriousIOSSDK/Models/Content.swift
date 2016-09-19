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
    var likeCount: Int? { get }
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

public class Content: ContentModel {
    public typealias ID = String
    
    public let id: ID?
    public let status: String?
    public let text: String?
    public let hashtags: [Hashtag]
    public let shareURL: NSURL?
    public let linkedURL: NSURL?
    public let postedAt: Timestamp?
    public let createdAt: Timestamp
    public let paginationTimestamp: Timestamp
    public let previewImages: [ImageAssetModel]
    public let assets: [ContentMediaAssetModel]
    public let type: ContentType
    public let isVIPOnly: Bool
    public let author: UserModel
    public let isRemotelyLikedByCurrentUser: Bool
    public let likeCount: Int?
    
    /// videoStartTime is the time this piece of video content started in our device time
    /// It is used to keep videos in sync for videos on stage
    public var localStartTime: NSDate?
    
    public let tracking: TrackingModel?

    // MARK: - Initializers
    
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
        
        self.isRemotelyLikedByCurrentUser = viewedContentJSON["viewer_engagements"]["is_liking"].bool ?? false
        self.likeCount = viewedContentJSON["total_engagements"]["likes"].int
        self.isVIPOnly = json["is_vip"].bool ?? false
        self.id = id
        self.status = json["status"].string
        self.shareURL = json["share_url"].URL
        self.postedAt = Timestamp(apiString: json["posted_at"].stringValue)
        self.createdAt = Timestamp(apiString: json["released_at"].stringValue) ?? Timestamp()
        self.paginationTimestamp = Timestamp(apiString: viewedContentJSON["pagination_timestamp"].stringValue) ?? Timestamp()
        self.hashtags = []
        self.type = type
        
        if type == .text {
            self.text = json[typeString]["data"].string
        }
        else {
            self.text = json["title"].string
        }
        
        self.author = author
        self.linkedURL = NSURL(string: json[typeString]["data"].stringValue)
        
        self.previewImages = (json["preview"][previewType]["assets"].array ?? []).flatMap { ImageAsset(json: $0) }
        
        let sourceType = json[typeString]["type"].string ?? typeString
        
        switch type {
            case .image:
                self.assets = [ContentMediaAsset(contentType: type, sourceType: sourceType, json: json[typeString])].flatMap { $0 }
            case .gif, .video:
                self.assets = (json[typeString][sourceType].array ?? []).flatMap { ContentMediaAsset(contentType: type, sourceType: sourceType, json: $0) }
            case .text, .link:
                self.assets = []
        }
        
        self.tracking = Tracking(json: json["tracking"])
    }
    
    public init?(chatMessageJSON json: JSON, serverTime: Timestamp) {
        guard let user = User(json: json["user"]) else {
            return nil
        }
        
        author = user
        createdAt = serverTime
        postedAt = nil
        paginationTimestamp = serverTime
        text = json["text"].string
        assets = [ContentMediaAsset(forumJSON: json["asset"])].flatMap { $0 }
        
        id = nil
        status = nil
        hashtags = []
        shareURL = nil
        linkedURL = nil
        previewImages = []
        self.type = assets.first?.contentType ?? .text
        isVIPOnly = false
        isRemotelyLikedByCurrentUser = false
        self.likeCount = nil

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
        localStartTime: NSDate? = nil,
        isVIPOnly: Bool = false
    ) {
        self.author = author
        self.id = id
        self.postedAt = postedAt
        self.createdAt = createdAt
        self.paginationTimestamp = paginationTimestamp
        self.type = type
        self.text = text
        self.assets = assets
        self.previewImages = previewImages
        self.localStartTime = localStartTime
        self.isVIPOnly = isVIPOnly
        
        self.status = nil
        self.hashtags = []
        self.shareURL = nil
        self.linkedURL = nil
        self.tracking = nil
        isRemotelyLikedByCurrentUser = false
        self.likeCount = nil
    }
}
