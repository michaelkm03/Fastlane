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
    
    fileprivate let requestExecutor = MainRequestExecutor()
    
    func downloadTemplateWithCompletion(_ completion: VTemplateDownloaderCompletion) {
        let templateRequest = TemplateRequest()
        dispatch_get_global_queue(DispatchQueue.GlobalQueuePriority.default, 0).async {
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
