//
//  ContentMediaAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// The source of where the video is hosted.
/// - note: We currently only need to differentiate Youtube videos from other videos.
/// (Giphy is indifferent from other videos as of now.)
public enum ContentVideoAssetSource {
    case youtube
    case video
}

/// Conformers are models that store information about content media asset.
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
public protocol ContentMediaAssetModel {
    /// Returns either the youtube ID or the remote URL that links to the content
    var resourceID: String { get }
    
    /// String describing the source. May return "youtube", "giphy", or nil.
    var source: String? { get }
    
    /// Returns where the video is hosted remotely
    var videoSource: ContentVideoAssetSource? { get }
    
    /// The asset's content type.
    var contentType: ContentType { get }
    
    /// The URL to the asset's content.
    var url: NSURL? { get }
    
    /// The YouTube or Giphy external ID of the content.
    var externalID: String? { get }
}

public enum ContentMediaAsset: ContentMediaAssetModel {
    case video(url: NSURL, source: String?)
    case youtube(remoteID: String, source: String?)
    case gif(remoteID: String?, url: NSURL, source: String?)
    case image(url: NSURL)
    
    public struct RemoteAssetParameters {
        public let contentType: ContentType
        public let url: NSURL
        public let source: String?
        public init(contentType: ContentType, url: NSURL, source: String?) {
            self.contentType = contentType
            self.url = url
            self.source = source
        }
    }
    
    public struct LocalAssetParameters {
        public let contentType: ContentType
        public let remoteID: String
        public let source: String?
        public let url: NSURL?
        public init(contentType: ContentType, remoteID: String, source: String?, url: NSURL? = nil) {
            self.contentType = contentType
            self.remoteID = remoteID
            self.source = source
            self.url = url
        }
    }
    
    public init?(contentType: ContentType, sourceType: String, json: JSON) {
        switch contentType {
            case .image:
                guard let url = json["data"].URL else {
                    return nil
                }
                self = .image(url: url)
            case .video, .gif:
                var url: NSURL?
                
                switch sourceType {
                case "video_assets":
                    url = json["data"].URL
                case "remote_assets":
                    url = json["remote_content_url"].URL
                default:
                    return nil
                }
                
                let source = json["source"].string
                let externalID = json["external_id"].string
                
                if contentType == .video {
                    if let source = source,
                        let externalID = externalID where source == "youtube" {
                        self = .youtube(remoteID: externalID, source: source)
                    } else if let url = url {
                        self = .video(url: url, source: source)
                    } else {
                        return nil
                    }
                } else if contentType == .gif {
                    guard let url = url else {
                        return nil
                    }
                    self = .gif(remoteID: externalID, url: url, source: source)
                } else {
                    return nil
                }
            case .text, .link:
                return nil
        }
    }
    
    public init?(initializationParameters parameters: RemoteAssetParameters) {
        self.init(contentType: parameters.contentType, source: parameters.source, url: parameters.url)
    }
    
    public init?(initializationParameters parameters: LocalAssetParameters) {
        self.init(contentType: parameters.contentType, source: parameters.source, remoteID: parameters.remoteID, url: parameters.url)
    }
    
    private init?(contentType: ContentType, source: String?, remoteID: String? = nil, url: NSURL? = nil) {
        guard url != nil || remoteID != nil else {
            // By using the initialziation structs, we should NEVER make it here
            assertionFailure("invalid initialization parameters provided to \(#function)")
            return nil
        }
        
        switch contentType {
            case .text, .link:
                return nil
            case .video:
                if source == "youtube" {
                    guard let remoteID = remoteID else {
                        return nil
                    }
                    self = .youtube(remoteID: remoteID, source: source)
                }
                else {
                    guard let url = url else {
                        return nil
                    }
                    self = .video(url: url, source: source)
                }
            case .gif:
                guard let url = url else {
                    return nil
                }
                self = .gif(remoteID: remoteID, url: url, source: source)
            case .image:
                guard let url = url else {
                    return nil
                }
                self = .image(url: url)
        }
    }
    
    public init?(forumJSON json: JSON) {
        guard let url = NSURL(vsdk_string: json["url"].string) else {
            return nil
        }
        
        switch json["type"].stringValue.lowercaseString {
            case "image": self = .image(url: url)
            case "video": self = .video(url: url, source: nil)
            case "gif": self = .gif(remoteID: nil, url: url, source: nil)
            default: return nil
        }
    }
    
    /// URL pointing to the resource.
    public var url: NSURL? {
        switch self {
            case .youtube(_, _): return nil
            case .video(let url, _): return url
            case .gif(_, let url, _): return url
            case .image(let url): return url
        }
    }
    
    /// String describing the source. May return "youtube", "giphy", or nil.
    public var source: String? {
        switch self {
            case .youtube(_, let source): return source
            case .video(_, let source): return source
            case .gif(_, _, let source): return source
            default: return nil
        }
    }
    
    /// String for the external ID
    public var externalID: String? {
        switch self {
            case .youtube(let externalID, _): return externalID
            case .gif(let externalID, _, _): return externalID
            default: return nil
        }
    }
    
    public var uniqueID: String {
        switch self {
            case .youtube(let externalID, _): return externalID
            case .video(let url, _): return url.absoluteString
            case .gif(_, let url, _): return url.absoluteString
            case .image(let url): return url.absoluteString
        }
    }
    
    public var contentType: ContentType {
        switch self {
            case .youtube(_, _), .video(_, _): return .video
            case .gif(_, _, _): return .gif
            case .image(_): return .image
        }
    }
    
    // MARK: - ContentMediaAssetModel
    
    public var resourceID: String {
        return uniqueID
    }
    
    public var videoSource: ContentVideoAssetSource? {
        switch self {
            case .video(_, _), .gif(_, _, _): return .video
            case .youtube(_, _): return .youtube
            case .image(_): return nil
        }
    }
}
