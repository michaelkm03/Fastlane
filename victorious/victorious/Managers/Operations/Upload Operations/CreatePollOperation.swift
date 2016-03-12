//
//  CreatePollOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class CreatePollOperation: BackgroundOperation, RequestOperation {
    
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
    
    private func upload(uploadManager: VUploadManager) {
        let formFields = self.formFields
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)
        taskCreator.request = request.urlRequest
        taskCreator.formFields = formFields
        taskCreator.previewImage = previewImage
        
        do {
            let task = try taskCreator.createUploadTask()
            uploadManager.enqueueUploadTask(task) { _ in
                self.finishedExecuting()
            }
            
            if let answer1media = formFields["answer1_media"] as? NSURL {
                // "try?" instead of "try" because if this delete fails, we don't want to fall through to the catch block; let's keep going and delete the other file at least.
                let _ = try? NSFileManager.defaultManager().removeItemAtURL(answer1media)
            }
            if let answer2media = formFields["answer2_media"] as? NSURL {
                let _ = try? NSFileManager.defaultManager().removeItemAtURL(answer2media)
            }
        } catch {
            return
        }
    }
}
