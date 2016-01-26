//
//  PersistenceTemplateDownloader.swift
//  victorious
//
//  Created by Josh Hinman on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class PersistenceTemplateDownloader: NSObject, VTemplateDownloader {
    
    private let requestExecutor = MainRequestExecutor()
    
    func downloadTemplateWithCompletion(completion: VTemplateDownloaderCompletion) {
        let templateRequest = TemplateRequest()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.requestExecutor.executeRequest(templateRequest, onComplete: { (templateData: NSData, end: () -> Void) in
                    completion(templateData, nil)
                    end()
                }, onError: { (error: NSError, end: () -> Void) in
                    completion(nil, error)
                    end()
            })
        }
    }
}
