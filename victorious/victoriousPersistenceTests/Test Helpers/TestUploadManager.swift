//
//  TestUploadManager.swift
//  victorious
//
//  Created by Tian Lan on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
@testable import victorious

class TestUploadManager: VUploadManager {
    private(set) var enqueuedTasksCount = 0
    
    override func enqueueUploadTask(_ uploadTask: VUploadTaskInformation!, onComplete: VUploadManagerTaskCompleteBlock!) {
        enqueuedTasksCount += 1
    }
}
