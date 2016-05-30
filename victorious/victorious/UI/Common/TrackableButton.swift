//
//  TrackableButton.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Describes a template-styled button,
/// provides default implementations for easy subclassing.
protocol TrackableButton {
    
    var dependencyManager: VDependencyManager! { get set }
    
    var trackingId: String { get }
    
    func templateAppearanceValue<T>(appearance: TrackableButtonAppearance) -> T?
}

extension TrackableButton {
    
    var trackingId: String {
        return dependencyManager.stringForKey("id")
    }
    
    func templateAppearanceValue<T>(appearance: TrackableButtonAppearance) -> T? {
        switch appearance {
        case .backgroundColor, .foregroundColor:
            return dependencyManager.colorForKey(appearance.rawValue) as? T
        case .backgroundImage, .foregroundImage:
            return dependencyManager.imageForKey(appearance.rawValue) as? T
        case .text:
            return dependencyManager.stringForKey(appearance.rawValue) as? T
        case .font:
            return dependencyManager.fontForKey(appearance.rawValue) as? T
        }
    }
}

/// A set of values used to cleanly access button appearance values
/// via the `templateAppearanceValue` method of `TrackableButton`.
enum TrackableButtonAppearance: String {
    case backgroundColor = "color.background"
    case backgroundImage = "image.background"
    case foregroundColor = "color.foreground"
    case foregroundImage = "image.foreground"
    case text = "text"
    case font = "font"
}

/// Public dependency manager extension for getting a button from the template.
extension VDependencyManager {
    
    func buttonForKey(key: String) -> UIButton? {
        return templateValueOfType(UIButton.self, forKey: key) as? UIButton
    }
}
