//
//  ShowCloseUpOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

enum CloseUpContentType {
    case Image
    case GIF
    case Video
    case Youtube
}

protocol CloseUpContent {
    var title: String { get }
    var contentType: CloseUpContentType { get }
    var mediaURL: NSURL? { get }
    var previewImageURL: NSURL { get }
    var aspectRatio: CGFloat { get }
    var user: VUser { get }
    var creationDate: NSDate? { get }
    var remoteID: String? { get }
}

class CUVContent: NSObject, CloseUpContent {
    var title: String
    var contentType: CloseUpContentType
    var mediaURL: NSURL?
    var previewImageURL: NSURL
    var aspectRatio: CGFloat
    var user: VUser
    var creationDate: NSDate?
    var remoteID: String?
    init(title: String,
         contentType: CloseUpContentType,
         mediaURL: NSURL? = nil,
         remoteID: String? = nil,
         previewImageURL: NSURL,
         aspectRatio: CGFloat,
         user: VUser,
         creationDate: NSDate?) {
        
        self.title = title
        self.contentType = contentType
        self.mediaURL = mediaURL
        self.remoteID = remoteID
        self.previewImageURL = previewImageURL
        self.aspectRatio = aspectRatio
        self.user = user
        self.creationDate = creationDate
    }
}

class ShowCloseUpOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private weak var originViewController: UIViewController?
    private var content: CloseUpContent
    
    // TODO: - remove testing code
    init( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          sequence: VSequence) {
        
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = true
        
        var contentType: CloseUpContentType = .Image
        if sequence.isVideo() {
            if sequence.isGIFVideo() {
                contentType = .GIF
            }
            else if sequence.isRemoteVideoWithSource(YouTubeVideoSequencePreviewView.remoteSourceName()) {
                contentType = .Youtube
            }
            else {
                contentType = .Video
            }
            self.content = CUVContent(title: sequence.name ?? "",
                                      contentType: contentType,
                                      mediaURL: sequence.firstNode().mp4Asset().dataURL(),
                                      remoteID: sequence.firstNode().mp4Asset().remoteContentId,
                                      previewImageURL: sequence.previewImageUrl()!,
                                      aspectRatio: sequence.previewAssetAspectRatio(),
                                      user: sequence.user,
                                      creationDate: sequence.releasedAt)
        }
        else {
            self.content = CUVContent(title: sequence.name ?? "",
                                      contentType: contentType,
                                      previewImageURL: sequence.previewImageUrl()!,
                                      aspectRatio: sequence.previewAssetAspectRatio(),
                                      user: sequence.user,
                                      creationDate: sequence.releasedAt)
        }
        
        
    }
    
    init( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          content: CloseUpContent,
          animated: Bool = true) {
        
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.content = content
    }
    
    override func start() {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("contentScreen")
            where !self.cancelled else {
            finishedExecuting()
            return
        }
        defer {
            finishedExecuting()
        }
        
        let header = CloseUpView.newWithDependencyManager(childDependencyManager)
        let apiPath = ""
        
        let closeUpViewController = GridStreamViewController<CloseUpView>.newWithDependencyManager(
            childDependencyManager,
            header: header,
            content: content,
            streamAPIPath: apiPath
        )
        originViewController?.navigationController?.pushViewController(closeUpViewController, animated: animated)
    }
    
}
