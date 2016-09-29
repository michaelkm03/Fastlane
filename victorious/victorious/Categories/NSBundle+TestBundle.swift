//
//  NSBundle+TestBundle.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension Bundle {
    static var v_isTestBundle: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["XCInjectBundleInto"] != nil || environment["XCInjectBundle"] != nil
    }
}
