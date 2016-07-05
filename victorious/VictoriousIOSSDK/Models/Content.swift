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
    var createdAt: NSDate { get }
    var type: ContentType { get }
    var id: Content.ID? { get }
    var isLikedByCurrentUser: Bool { get }
    var text: String? { get }
    var hashtags: [Hashtag] { get }
    var shareURL: NSURL? { get }
    var linkedURL: NSURL? { get }
    var author: UserModel { get }
    
    /// Whether this content is only accessible for VIPs
    var isVIPOnly: Bool { get }
    
    /// An array of preview images for the content.
    var previewImages: [ImageAssetModel] { get }
    
    /// An array of media assets for the content, could be any media type
    var assets: [ContentMediaAssetModel] { get }
    
    /// seekAheadTime to keep videos in sync for videos on VIP stage
    var seekAheadTime: NSTimeInterval? { get set }
    
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
}

public class Content: ContentModel {
    
    public typealias ID = String
    
    public let id: ID?
    public let status: String?
    public let text: String?
    public let hashtags: [Hashtag]
    public let shareURL: NSURL?
    public let linkedURL: NSURL?
    public let createdAt: NSDate
    public let previewImages: [ImageAssetModel]
    public let assets: [ContentMediaAssetModel]
    public let type: ContentType
    public let isVIPOnly: Bool
    public let author: UserModel
    public let isLikedByCurrentUser: Bool
    
    /// seekAheadTime for videos to be played on the VIP stage (which needs synchronization)
    public var seekAheadTime : NSTimeInterval?
    
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
        self.createdAt = NSDate(millisecondsSince1970: json["released_at"].doubleValue)
        self.hashtags = []
        self.type = type
        
        if (type == .text) {
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
    
    public init?(chatMessageJSON json: JSON, serverTime: NSDate) {
        guard
            let user = User(json: json["user"])
        else {
            return nil
        }
        
        author = user
        createdAt = serverTime
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
        createdAt: NSDate = NSDate(),
        type: ContentType = .text,
        text: String? = nil,
        assets: [ContentMediaAssetModel] = [],
        previewImages: [ImageAssetModel] = [],
        author: UserModel
    ) {
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.text = text
        self.assets = assets
        self.previewImages = previewImages
        self.author = author
        
        self.status = nil
        self.hashtags = []
        self.shareURL = nil
        self.linkedURL = nil
        self.isVIPOnly = false
        self.tracking = nil
        isLikedByCurrentUser = false
    }
}
