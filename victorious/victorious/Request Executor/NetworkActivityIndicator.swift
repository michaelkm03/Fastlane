//
//  NetworkActivityIndicator.swift
//  victorious
//
//  Created by Patrick Lynch on 12/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public class NetworkActivityIndicator {
    
    private(set) var activityCount: Int = 0
    
    private static var instance = NetworkActivityIndicator()
    
    public static func sharedInstance() -> NetworkActivityIndicator {
        return instance
    }
    
    init() {}
    
    public func start() {
        activityCount += 1
        self.update()
    }
    
    public func stop() {
        if activityCount > 0 {
            activityCount -= 1
        }
        self.update()
    }
    
    var visible: Bool {
        return activityCount > 0
    }
    
    func update() {
        let newValue = visible
        let oldValue = UIApplication.sharedApplication().networkActivityIndicatorVisible
        if oldValue != newValue {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = newValue
        }
    }
}
