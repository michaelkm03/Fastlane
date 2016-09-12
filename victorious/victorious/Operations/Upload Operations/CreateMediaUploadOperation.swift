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

final class CreateMediaUploadOperation: SyncOperation<Void> {
    
    let request: MediaUploadCreateRequest
    let uploadManager: VUploadManager
    let publishParameters: VPublishParameters
    let mediaURL: NSURL?
    
    private var currentUploadTask: VUploadTaskInformation?
    
    init(publishParameters: VPublishParameters, uploadManager: VUploadManager, apiPath: APIPath) {
        self.mediaURL = publishParameters.mediaToUploadURL
        self.request = MediaUploadCreateRequest(apiPath: apiPath)
        self.publishParameters = publishParameters
        self.uploadManager = uploadManager
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        let uploadError = NSError(domain: "UploadError", code: -1, userInfo: nil)
        if !publishParameters.isGIF && mediaURL == nil {
            return .failure(uploadError)
        }
        
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)
        let authenticationContext = AuthenticationContext()
        
        taskCreator.request = request.urlRequestWithHeaders(using: RequestContext(), authenticationContext: authenticationContext)
        taskCreator.formFields = formFields
        taskCreator.isGIF = publishParameters.isGIF
        taskCreator.previewImage = publishParameters.previewImage
        
        do {
            currentUploadTask = try taskCreator.createUploadTask()
            uploadManager.enqueueUploadTask(currentUploadTask) { _ in }
        } catch {
            return .failure(uploadError)
        }
        
        return .success()
    }
    
    override func cancel() {
        super.cancel()
        guard let currentUploadTask = currentUploadTask else {
            return
        }
        uploadManager.cancelUploadTask(currentUploadTask)
    }
    
    private var formFields: [NSObject : AnyObject] {
        var dict: [NSObject : AnyObject] = [
            "name": publishParameters.caption ?? "",
            "is_gif_style": publishParameters.isGIF ? "true" : "false",
            "did_crop": publishParameters.didCrop ? "true" : "false",
            "did_trim": publishParameters.didTrim ? "true" : "false",
            "is_vip": publishParameters.isVIPContent ? "true" : "false"
        ]
        
        /// Assumption here is that we don't need to send both the assetRemoteID and mediaURL
        if let assetRemoteID = publishParameters.assetRemoteId {
            dict["remote_id"] = assetRemoteID
            dict["remote_width"] = "\(publishParameters.width)"
            dict["remote_height"] = "\(publishParameters.height)"
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
        if let source = publishParameters.source {
            dict["source"] = source
        }
        
        return dict
    }
}
