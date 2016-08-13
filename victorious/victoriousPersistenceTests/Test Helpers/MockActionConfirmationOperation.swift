//
//  MockActionConfirmationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
@testable import victorious

final class MockActionConfirmationOperation: AsyncOperation<Void>, ActionConfirmationOperation {
    
    var didConfirmAction: Bool = false
    let shouldConfirm: Bool
    
    init(shouldConfirm: Bool) {
        self.shouldConfirm = shouldConfirm
    }
    
    override var executionQueue: NSOperationQueue {
        return .mainQueue()
    }
    
    override func execute(finish: (result: OperationResult<Output>) -> Void) {
        didConfirmAction = shouldConfirm
        finish(result: .success())
    }
}
