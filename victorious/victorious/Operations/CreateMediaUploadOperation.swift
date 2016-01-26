//
//  CreateMediaUploadOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import FBSDKCoreKit

class CreateMediaUploadOperation: Operation {
    
    let request: MediaUploadCreateRequest
    let uploadManager: VUploadManager
    let publishParameters: VPublishParameters
    let mediaURL: NSURL?
    let uploadCompletion: (NSError?) -> Void
    
    init(publishParameters: VPublishParameters, uploadManager: VUploadManager, uploadCompletion: (NSError?) -> Void) {
        let baseURL = VEnvironmentManager.sharedInstance().currentEnvironment.baseURL
        
        self.mediaURL = publishParameters.mediaToUploadURL
        self.request = MediaUploadCreateRequest(baseURL: baseURL)
        self.publishParameters = publishParameters
        self.uploadManager = uploadManager
        self.uploadCompletion = uploadCompletion
    }
    
    override func start() {
        super.start()
        upload(uploadManager)
    }
    
    private func upload(uploadManager: VUploadManager) {
        guard let mediaURL = formFields["media_data"] where !mediaURL.absoluteString.isEmpty else {
            uploadCompletion(NSError(domain: "UploadError", code: -1, userInfo: nil))
            return
        }
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)
        taskCreator.request = request.urlRequest
        taskCreator.formFields = formFields
        taskCreator.previewImage = publishParameters.previewImage
        
        do {
            let task = try taskCreator.createUploadTask()
            uploadManager.enqueueUploadTask(task) { _ in }
        } catch {
            uploadCompletion(NSError(domain: "UploadError", code: -1, userInfo: nil))
            return
        }

        dispatch_async(dispatch_get_main_queue()) {
            self.uploadCompletion(nil)
            self.mainQueueCompletionBlock?(self)
        }
    }
    
    private var formFields: [NSObject : AnyObject] {
        var dict: [NSObject : AnyObject] = [
            "name" : publishParameters.caption,
            "media_data" : mediaURL ?? NSURL(string: "")!,
            "is_gif_style" : publishParameters.isGIF ? "true" : "false",
            "did_crop" : publishParameters.didCrop ? "true" : "false",
            "did_trim" : publishParameters.didTrim ? "true" : "false",
        ]
        
        if let filterName = publishParameters.filterName {
            dict["filter_name"] = filterName
        }
        if let embeddedText = publishParameters.embeddedText {
            dict["embedded_text"] = embeddedText
        }
        if let textToolType = publishParameters.textToolType {
            dict["text_tool_type"] = textToolType
        }
        if let parentNodeID = publishParameters.parentNodeID where !parentNodeID.isEqualToNumber(NSNumber(int: 0)) {
            dict["parent_node_id"] = parentNodeID
        }
        if let parentSequenceID = publishParameters.parentSequenceID where !parentSequenceID.isEmpty {
            dict["parent_sequence_id"] = parentSequenceID
        }
        switch publishParameters.captionType {
        case .Meme:
            dict["subcategory"] = "meme"
        case .Quote:
            dict["subcategory"] = "secret"
        case .Normal:
            break
        }
        if publishParameters.shareToFacebook {
            dict["facebook_access_token"] = FBSDKAccessToken.currentAccessToken().tokenString
        }
        if (publishParameters.shareToTwitter) {
            dict["twitter_access_token"] = VTwitterManager.sharedManager().oauthToken
            dict["twitter_access_secret"] = VTwitterManager.sharedManager().secret
        }
        if let source = publishParameters.source {
            dict["source"] = source
        }
        if let assetRemoteID = publishParameters.assetRemoteId {
            dict["remote_id"] = assetRemoteID
        }
        
        return dict
    }
}