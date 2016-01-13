//
//  NSBundle+TestBundle.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension NSBundle {
    static var isTestBundle: Bool {
        let environment = NSProcessInfo.processInfo().environment
        return environment["XCInjectBundleInto"] != nil || environment["XCInjectBundle"] != nil
    }
}
