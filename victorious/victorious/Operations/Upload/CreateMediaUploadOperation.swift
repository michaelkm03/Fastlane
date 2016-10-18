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
    let mediaURL: URL?
    
    private var currentUploadTask: VUploadTaskInformation?
    
    init?(apiPath: APIPath, publishParameters: VPublishParameters, uploadManager: VUploadManager) {
        guard let request = MediaUploadCreateRequest(apiPath: apiPath) else {
            return nil
        }
        
        self.mediaURL = publishParameters.mediaToUploadURL
        self.request = request
        self.publishParameters = publishParameters
        self.uploadManager = uploadManager
    }
    
    override var executionQueue: Queue {
        return .background
    }

    private func isPublishable(publishParameters: VPublishParameters) -> Bool {
        // A GIF needs either a URL refrence or a remote ID any other type only needs a mediaURL.
        if publishParameters.isGIF {
            return mediaURL != nil || publishParameters.assetRemoteId != nil
        } else {
            return mediaURL != nil
        }
    }
    
    override func execute() -> OperationResult<Void> {
        let uploadError = NSError(domain: "UploadError", code: -1, userInfo: nil)

        guard isPublishable(publishParameters: publishParameters) else {
            return .failure(uploadError)
        }
        
        // Future: Fix the ! imported from Objc
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)!
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
    
    private var formFields: [AnyHashable: Any] {
        var dict: [AnyHashable: Any] = [
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
        if let parentNodeID = publishParameters.parentNodeID , !parentNodeID.isEqual(to: NSNumber(value: 0)) {
            dict["parent_node_id"] = String(describing: parentNodeID)
        }
        if let parentSequenceID = publishParameters.parentSequenceID , !parentSequenceID.isEmpty {
            dict["parent_sequence_id"] = String(parentSequenceID)
        }
        switch publishParameters.captionType {
        case .meme:
            dict["subcategory"] = "meme"
        case .normal:
            break
        }
        if let source = publishParameters.source {
            dict["source"] = source
        }
        
        return dict
    }
}
