//
//  ShowCloseUpOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

//enum CloseUpContentType {
//    case Image
//    case GIF
//    case Video
//    case Youtube
//}
//
//protocol CloseUpContent {
//    var title: String { get }
//    var contentType: CloseUpContentType { get }
//    var mediaURL: NSURL? { get }
//    var previewImageURL: NSURL { get }
//    var aspectRatio: CGFloat { get }
//    var user: VUser { get }
//    var creationDate: NSDate? { get }
//    var remoteID: String? { get }
//}
//
//class CUVContent: NSObject, CloseUpContent {
//    var title: String
//    var contentType: CloseUpContentType
//    var mediaURL: NSURL?
//    var previewImageURL: NSURL
//    var aspectRatio: CGFloat
//    var user: VUser
//    var creationDate: NSDate?
//    var remoteID: String?
//    init(title: String,
//         contentType: CloseUpContentType,
//         mediaURL: NSURL? = nil,
//         remoteID: String,
//         previewImageURL: NSURL,
//         aspectRatio: CGFloat,
//         user: VUser,
//         creationDate: NSDate?) {
//        
//        self.title = title
//        self.contentType = contentType
//        self.mediaURL = mediaURL
//        self.remoteID = remoteID
//        self.previewImageURL = previewImageURL
//        self.aspectRatio = aspectRatio
//        self.user = user
//        self.creationDate = creationDate
//    }
//}

class ShowCloseUpOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private weak var originViewController: UIViewController?
    private var content: VViewedContent?
    var fetcherOperation: ViewedContentFetchOperation
    
    init( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          contentID: String) {
        
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = true
        
        let userID = VCurrentUser.user()!.remoteId.integerValue ?? 0
        
        let request = ViewedContentFetchRequest(
            macroURLString: "https://vapi-dev.getvictorious.com/v1/content/%%SEQUENCE_ID%%/user/%%USER_ID%%",
            currentUserID: "\(userID)",
            contentID: contentID
            )!
        
        fetcherOperation = ViewedContentFetchOperation(request: request)
        super.init()
        
        fetcherOperation.before(self).queue() { results, error, cancelled in
            if let content = results?.first as? VViewedContent {
                self.content = content
            }
        }
    }
    
    override func start() {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("closeUpView"),
            content = content
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
