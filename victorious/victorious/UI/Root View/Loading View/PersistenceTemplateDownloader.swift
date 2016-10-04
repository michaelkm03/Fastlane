//
//  PersistenceTemplateDownloader.swift
//  victorious
//
//  Created by Josh Hinman on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import VictoriousCommon

class PersistenceTemplateDownloader: NSObject, VTemplateDownloader {
    private let requestExecutor = MainRequestExecutor()
    
    func downloadTemplate(completion: @escaping VTemplateDownloaderCompletion) {
        let templateRequest = TemplateRequest()
        
        DispatchQueue.global().async {
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
