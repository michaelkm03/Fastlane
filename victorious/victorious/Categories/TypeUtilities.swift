//
//  TypeUtilities.swift
//  victorious
//
//  Created by Josh Hinman on 8/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Returns the name of a class by itself (without any package name)
func StringFromClass(aClass: AnyClass) -> String {
    return (NSStringFromClass(aClass) as NSString).pathExtension
}
