//
//  Content.swift
//  victorious
//
//  Created by Sebastian Nystorm on 25/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import CoreGraphics
import Foundation

var ids: Set<Content.ID> = Set()

/// Conformers are models that store information about piece of content in the app
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
public protocol ContentModel: PreviewImageContainer, DictionaryConvertible {
    var type: ContentType { get }
    var id: Content.ID? { get }
    var isLikedByCurrentUser: Bool { get }
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
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool { get }
    
    /// An array of preview images for the content.
    var previewImages: [ImageAssetModel] { get }
    
    /// An array of media assets for the content, could be any media type
    var assets: [ContentMediaAssetModel] { get }
    
    /// videoStartTime is the time this piece of video content started in our device time
    /// It is used to keep videos in sync for videos on stage
    var videoStartTime: NSDate? { get set }
    
    /// Keys correspond to an array of string-represented tracking urls
    var tracking: TrackingModel? { get }
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
    
    public func seekAheadTime() -> NSTimeInterval {
        guard let videoStartTime = videoStartTime else {
            return 0
        }
        
        return NSDate().timeIntervalSinceDate(videoStartTime)
    }
}

extension ContentModel {
    
    // MARK: Hidden Content
    
    public static func hideContent(withID id: Content.ID) {
        ids.insert(id)
    }
    
    public static func contentIsHidden(withID id: Content.ID) -> Bool {
        return ids.contains(id)
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
    public let createdAt: Timestamp
    public let postedAt: Timestamp?
    public let previewImages: [ImageAssetModel]
    public let assets: [ContentMediaAssetModel]
    public let type: ContentType
    public let isVIPOnly: Bool
    public let author: UserModel
    public let isLikedByCurrentUser: Bool
    
    /// videoStartTime for videos to be played on the VIP stage (which needs synchronization)
    public var videoStartTime : NSDate?
    
    public let tracking: TrackingModel?
    
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
        
        self.isLikedByCurrentUser = viewedContentJSON["viewer_engagements"]["is_liking"].bool ?? false
        self.isVIPOnly = json["is_vip"].bool ?? false
        self.id = id
        self.status = json["status"].string
        self.shareURL = json["share_url"].URL
        self.createdAt = Timestamp(apiString: json["released_at"].stringValue) ?? Timestamp()
        self.postedAt = Timestamp(apiString: json["posted_at"].stringValue)
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
        isLikedByCurrentUser = false
        tracking = nil //Tracking is not returned on chat messages
        
        // Either one of these types are required to be counted as a chat message.
        guard text != nil || assets.count > 0 else {
            return nil
        }
    }
    
    public init(
        id: String? = nil,
        createdAt: Timestamp = Timestamp(),
        postedAt: Timestamp = Timestamp(),
        type: ContentType = .text,
        text: String? = nil,
        assets: [ContentMediaAssetModel] = [],
        previewImages: [ImageAssetModel] = [],
        author: UserModel,
        videoStartTime: NSDate? = nil
    ) {
        self.id = id
        self.postedAt = postedAt
        self.createdAt = createdAt
        self.type = type
        self.text = text
        self.assets = assets
        self.previewImages = previewImages
        self.author = author
        self.videoStartTime = videoStartTime
        
        self.status = nil
        self.hashtags = []
        self.shareURL = nil
        self.linkedURL = nil
        self.isVIPOnly = false
        self.tracking = nil
        isLikedByCurrentUser = false
    }
}
