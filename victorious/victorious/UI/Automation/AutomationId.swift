//
//  AutomationId.swift
//  victorious
//
//  Created by Patrick Lynch on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Strings to be used for `accessibilityIdentifier` value of views that will involved
/// in UI automation testing.  This is for Swift code only.  There is an equivalent file
/// for use in Objective-C called "VAutomation.h" that defines static constant strings.
public enum AutomationId: String {
    case None = ""
    case MediaSearchNext = "GIF Search Next"
    case MediaSearchSearchbar = "GIF Search Searchbar"
    case MediaSearchCollection = "GIF Search Collection"
}