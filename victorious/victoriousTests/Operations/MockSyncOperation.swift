//
//  MockSyncOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 10/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import victorious

class MockOperation<MockDataType>: SyncOperation<MockDataType> {
    let mockResult: OperationResult<MockDataType>

    override var executionQueue: Queue {
        return .background
    }

    init(mockResult: OperationResult<MockDataType>) {
        self.mockResult = mockResult
    }

    override func execute() -> OperationResult<MockDataType> {
        switch mockResult {
            case .success: return mockResult
            case .failure: return mockResult
            case .cancelled: return .cancelled
        }
    }
}
