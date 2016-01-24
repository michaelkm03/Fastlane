//
//  CreatePollOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class CreatePollOperation: Operation {
    
    /// `request` is implicitly unwrapped to solve the failable initializer EXC_BAD_ACCESS bug when returning nil
    /// Reference: Swift Documentation, Section "Failable Initialization for Classes":
    /// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html
    let request: PollCreateRequest!
    let previewImage: UIImage
    let uploadManager: VUploadManager
    
    var formFields: [NSObject : AnyObject] {
        let parameters = request.parameters
        var dict: [NSObject : AnyObject] = [ : ]
        
        dict["name"] = parameters.name
        dict["description"] = parameters.description
        dict["question"] = parameters.question
        dict["answer1_label"] = parameters.answers.first?.label
        dict["answer2_label"] = parameters.answers.last?.label
        dict["answer1_media"] = parameters.answers.first?.mediaURL
        dict["answer2_media"] = parameters.answers.last?.mediaURL
        
        return dict
    }
    
    init?(parameters: PollParameters, previewImage: UIImage, uploadManager: VUploadManager) {
        let baseURL = VEnvironmentManager.sharedInstance().currentEnvironment.baseURL
        self.request = PollCreateRequest(parameters: parameters, baseURL: baseURL)
        self.previewImage = previewImage
        self.uploadManager = uploadManager
        
        super.init()
        if request == nil {
            return nil
        }
    }
    
    override func start() {
        super.start()
        upload(uploadManager)
    }
    
    func upload(uploadManager: VUploadManager) {
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
