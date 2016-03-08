//
//  MockActionConfirmationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
@testable import victorious

class MockActionConfirmationOperation: NavigationOperation, ActionConfirmationOperation {
    
    var didConfirmAction: Bool = false
    let shouldConfirm: Bool
    
    init(shouldConfirm: Bool) {
        self.shouldConfirm = shouldConfirm
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        didConfirmAction = shouldConfirm
        self.finishedExecuting()
    }
}
