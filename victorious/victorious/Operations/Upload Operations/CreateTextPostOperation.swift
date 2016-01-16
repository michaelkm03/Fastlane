//
//  CreateTextPostOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CreateTextPostOperation: Operation {
    
    /// `request` is implicitly unwrapped to solve the failable initializer EXC_BAD_ACCESS bug when returning nil
    /// Reference: Swift Documentation, Section "Failable Initialization for Classes":
    /// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html
    let request: CreateTextPostRequest!
    let previewImage: UIImage
    let uploadManager: VUploadManager
    
    private var formFields: [NSObject : AnyObject] {
        let parameters = request.parameters
        var dict: [NSObject : AnyObject] = [ : ]
        
        dict["content"] = parameters.content
        dict["background_image"] = parameters.backgroundImageURL ?? ""
        dict["background_color"] = parameters.backgroundColor?.v_hexString() ?? ""
        
        return dict
    }

    init?(parameters: TextPostParameters, previewImage: UIImage, uploadManager: VUploadManager) {
        let baseURL = VEnvironmentManager.sharedInstance().currentEnvironment.baseURL
        self.request = CreateTextPostRequest(parameters: parameters, baseURL: baseURL)
        self.previewImage = previewImage
        self.uploadManager = uploadManager
        
        super.init()
        if request == nil {
            return nil
        }
    }

    override func start() {
        super.start()
        queueUploadTask(uploadManager)
    }
    
    private func queueUploadTask(uploadManager: VUploadManager) {
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)
        taskCreator.request = request.urlRequest
        taskCreator.formFields = formFields
        taskCreator.previewImage = previewImage
        
        do {
            let task = try taskCreator.createUploadTask()
            uploadManager.enqueueUploadTask(task) { _ in
                dispatch_async(dispatch_get_main_queue()) {
                    self.mainQueueCompletionBlock?(self)
                }
            }
        } catch {
            return
        }
    }
}
