//
//  AppVersion.swift
//  victorious
//
//  Created by Michael Sena on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// A struct that provides comparable protocol conformance for app versions.
struct AppVersion: Comparable {
    fileprivate let components: [Int]
    
    init(versionNumber : String) {
        components = versionNumber.components(separatedBy: ".").map { Int($0) ?? 0 }
    }
    
    /// The string value of an app version ex: "1.0.1"
    var string: String {
        return components.map { String($0) }.joined(separator: ".")
    }
}

func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
    if lhs.components.count == rhs.components.count {
        return lhs.components == rhs.components
    } else if lhs.components.count < rhs.components.count {
        return rhs.components.dropFirst(lhs.components.count).reduce(0, +) == 0
    } else {
        return lhs.components.dropFirst(rhs.components.count).reduce(0, +) == 0
    }
}

func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
    for (element1, element2) in zip(lhs.components, rhs.components) {
        if element1 < element2 {
            return true
        }
    }
    return false
}
