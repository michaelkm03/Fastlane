//
//  Queue.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// This enum represents the NSOperationQueues we use in the app. Each case is supported by an NSOperationQueue instance underneath.
/// - note:
/// This doesn't represent any of the GCD queues. Only the NSOperationQueues we use in our Operation Architecture.
/// If you add new cases to this enum, make sure to update its `allCases` property to guarantee correct behavior.
enum Queue {
    /// System Main Queue
    case main
    
    /// A background queue for to perform background tasks
    case background
    
    /// A queue to schedule all the async operations.
    /// - note: 
    /// This queue will be blocked while an asnyc operation is waiting for its callback.
    /// If you are writing an operation subclass, don't use this queue as an `executionQueue`.
    case asyncSchedule
    
    /// All cases in this enum.
    /// - note:
    /// It's unfortunate that Swift doesn't provide this functionality yet. 
    /// So please make sure to manually update this array if you add a new case to this enum.
    static let allCases: [Queue] = [.main, .background, .asyncSchedule]
    
    /// All `NSOperationQueue` instances represented in this enum
    static var allQueues: [OperationQueue] {
        return Queue.allCases.map { $0.operationQueue }
    }
    
    /// Returns the supporting NSOperationQueue based on which case `self` is.
    var operationQueue: OperationQueue {
        switch self {
            case .main: return OperationQueue.main
            case .background: return Queue.backgroundQueue
            case .asyncSchedule: return Queue.asyncScheduleQueue
        }
    }
    
    private static let backgroundQueue = OperationQueue()
    private static let asyncScheduleQueue = OperationQueue()
}
