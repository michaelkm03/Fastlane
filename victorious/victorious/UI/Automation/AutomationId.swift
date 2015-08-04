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
enum AutomationId: String {
    case None = ""
    case GIFSearchNext = "GIF Search Next"
    case GIFSearchSearchbar = "GIF Search Searchbar"
    case GIFSearchCollection = "GIF Search Collection"
}