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
    var dependencyManager: VDependencyManager? { get set }
    
    var trackingID: String? { get }
    
    func templateAppearanceValue<AppearanceValueType>(appearance: TrackableButtonAppearance) -> AppearanceValueType?
}

extension TrackableButton where Self: UIButton {
    var trackingID: String? {
        return dependencyManager?.stringForKey("id")
    }
    
    func templateAppearanceValue<AppearanceValueType>(appearance: TrackableButtonAppearance) -> AppearanceValueType? {
        guard let dependencyManager = dependencyManager else {
            return nil
        }
        switch appearance {
            case .backgroundColor, .foregroundColor:
                return dependencyManager.colorForKey(appearance.rawValue) as? AppearanceValueType
            case .backgroundImage, .foregroundImage:
                return dependencyManager.imageForKey(appearance.rawValue) as? AppearanceValueType
            case .text:
                return dependencyManager.stringForKey(appearance.rawValue) as? AppearanceValueType
            case .font:
                return dependencyManager.fontForKey(appearance.rawValue) as? AppearanceValueType
            case .clickable:
                return dependencyManager.numberForKey(appearance.rawValue) as? AppearanceValueType
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
    case text = "text.button"
    case font = "font.text.button"
    case clickable = "clickable"
}
