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

class CreateMediaUploadOperation: BackgroundOperation {
    
    let request: MediaUploadCreateRequest
    let uploadManager: VUploadManager
    let publishParameters: VPublishParameters
    let mediaURL: NSURL?
    let uploadCompletion: ((NSError?) -> Void)?
    
    private var currentUploadTask: VUploadTaskInformation?
    
    init(publishParameters: VPublishParameters, uploadManager: VUploadManager, apiPath: APIPath, uploadCompletion: ((NSError?) -> Void)?) {
        self.mediaURL = publishParameters.mediaToUploadURL
        self.request = MediaUploadCreateRequest(apiPath: apiPath)
        self.publishParameters = publishParameters
        self.uploadManager = uploadManager
        self.uploadCompletion = uploadCompletion
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        upload(uploadManager)
    }
    
    override func cancel() {
        super.cancel()
        guard let currentUploadTask = currentUploadTask else {
            return
        }
        uploadManager.cancelUploadTask(currentUploadTask)
    }
    
    private func completionError(error: NSError?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.uploadCompletion?(error)
            self.finishedExecuting()
        }
    }
    
    private func upload(uploadManager: VUploadManager) {
        if !publishParameters.isGIF && mediaURL == nil {
            completionError(NSError(domain: "UploadError", code: -1, userInfo: nil))
            return
        }
        
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)
        taskCreator.request = request.urlRequest
        taskCreator.formFields = formFields
        taskCreator.previewImage = publishParameters.previewImage
        
        do {
            currentUploadTask = try taskCreator.createUploadTask()
            uploadManager.enqueueUploadTask(currentUploadTask) { _ in }
        } catch {
            completionError(NSError(domain: "UploadError", code: -1, userInfo: nil))
            return
        }
        
        completionError(nil)
    }
    
    private var formFields: [NSObject : AnyObject] {
        var dict: [NSObject : AnyObject] = [
            "name": publishParameters.caption ?? "",
            "is_gif_style": publishParameters.isGIF ? "true" : "false",
            "did_crop": publishParameters.didCrop ? "true" : "false",
            "did_trim": publishParameters.didTrim ? "true" : "false",
        ]
        
        /// Assumption here is that we don't need to send both the assetRemoteID and mediaURL
        if let assetRemoteID = publishParameters.assetRemoteId {
            dict["remote_id"] = assetRemoteID
        } else if let mediaURL = mediaURL {
            dict["media_data"] = mediaURL
        }
        
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
            dict["parent_node_id"] = String(parentNodeID)
        }
        if let parentSequenceID = publishParameters.parentSequenceID where !parentSequenceID.isEmpty {
            dict["parent_sequence_id"] = String(parentSequenceID)
        }
        switch publishParameters.captionType {
        case .Meme:
            dict["subcategory"] = "meme"
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
        
        return dict
    }
}
