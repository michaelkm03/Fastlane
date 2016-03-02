//
//  VIPAppearanceSettings.swift
//  victorious
//
//  Created by Alex Tamoykin on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

struct VIPAppearanceSettings {
    let dependencyManager: VDependencyManager

    var greetingText: String {
        return self.dependencyManager.stringForKey(kVIPGreetingTextTemplateKey) ?? kVIPDefaultGreetingText
    }

    var greetingFont: UIFont {
        return self.dependencyManager.fontForKey(kVIPGreetingFontTemplateKey) ?? kVIPDefaultGreetingFont
    }

    var greetingColor: UIColor {
        return self.dependencyManager.colorForKey(kVIPGreetingColorTemplateKey) ?? kVIPDefaultGreetingColor
    }

    var subscribeColor: UIColor {
        return self.dependencyManager.colorForKey(kVIPSubscribeColorTemplateKey) ?? kVIPDefaultSubscribeColor
    }

    var subscribeText: String {
        return self.dependencyManager.stringForKey(kVIPSubscribeTextTemplateKey) ?? kVIPDefaultSubscribeText
    }

    var subscribeFont: UIFont {
        return self.dependencyManager.fontForKey(kVIPSubscribeFontTemplateKey) ?? kVIPDefaultSubscribeFont
    }

    var backgroundColor: UIColor {
        let background = self.dependencyManager.templateValueOfType(
            VSolidColorBackground.self,
            forKey: kVIPBackgroundTemplateKey) as? VSolidColorBackground
        return background?.backgroundColor ?? kVIPDefaultBackgroundColor
    }

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
}
