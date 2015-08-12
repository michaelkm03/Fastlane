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
    case GIFSearchNext = "GIF Search Next"
    case GIFSearchSearchbar = "GIF Search Searchbar"
    case GIFSearchCollection = "GIF Search Collection"
}


private var AssociatedObjectHandle: UInt8 = 0

public protocol VAutomationElement {
    var v_accessibilityIdentifier:String? { get set }
}

extension UIBarItem : VAutomationElement {
    public var v_accessibilityIdentifier:String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    var children: [AnyObject] {
        return []
    }
}

extension UIView : VAutomationElement {
    
    public var v_accessibilityIdentifier:String? {
        set {}
        get {
            return self.accessibilityIdentifier
        }
    }
}