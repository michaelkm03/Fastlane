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
            self.requestExecutor.executeRequest(templateRequest,
                onComplete: { templateData in
                    completion(templateData, nil)
                },
                onError: { error in
                    completion(nil, error)
                }
            )
        }
    }
}
