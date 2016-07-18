//
//  CreateTextPostOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class CreateTextPostOperation: FetcherOperation, RequestOperation {
    
    let request: TextPostCreateRequest!
    let previewImage: UIImage
    let uploadManager: VUploadManager
    
    var formFields: [NSObject : AnyObject] {
        let parameters = request.parameters
        var dict: [NSObject : AnyObject] = [ : ]
        
        dict["content"] = parameters.content
        
        if let backgroundImageURL = parameters.backgroundImageURL {
            dict["background_image"] = backgroundImageURL
        }
        dict["background_color"] = parameters.backgroundColor?.rgbHexString ?? ""
        
        return dict
    }

    init?(parameters: TextPostParameters, previewImage: UIImage, uploadManager: VUploadManager) {
        let baseURL = VEnvironmentManager.sharedInstance().currentEnvironment.baseURL
        self.request = TextPostCreateRequest(parameters: parameters, baseURL: baseURL)
        self.previewImage = previewImage
        self.uploadManager = uploadManager
        
        super.init()
        if request == nil {
            return nil
        }
    }
    
    override func main() {
        let formFields = self.formFields
        let taskCreator = VUploadTaskCreator(uploadManager: uploadManager)
        taskCreator.request = request.urlRequest
        taskCreator.formFields = formFields
        taskCreator.previewImage = previewImage
        
        do {
            let task = try taskCreator.createUploadTask()
            uploadManager.enqueueUploadTask(task) { _ in }
            
            if let backgroundImageURL = formFields["background_image"] as? NSURL {
                try NSFileManager.defaultManager().removeItemAtURL(backgroundImageURL)
            }
        } catch {
            return
        }
    }
}
