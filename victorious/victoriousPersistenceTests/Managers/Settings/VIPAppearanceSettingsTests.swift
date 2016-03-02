//
//  VIPAppearanceSettings.swift
//  victorious
//
//  Created by Alex Tamoykin on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class VIPAppearanceSettingsTests: XCTestCase {
    func testProvidedSettings() {
        let testGreetingText = "Welcome comrade!"
        let testGreetingFont = UIFont(name: "Arial", size: 5)!
        let testGreetingColor = UIColor(red: 10, green: 10, blue: 10, alpha: 0)
        let testSubscribeColor = UIColor(red: 20, green: 20, blue: 20, alpha: 0)
        let testSubscribeText = "Just hit this button to subscribe, it will be ok ;-)"
        let testSubscribeFont = UIFont(name: "Arial", size: 15)!
        let backgroundDependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        let testColorBackground = VSolidColorBackground(dependencyManager: backgroundDependencyManager)
        let dependencyManager = VDependencyManager(parentManager: nil,
            configuration: [
                kVIPGreetingTextTemplateKey: testGreetingText,
                kVIPGreetingFontTemplateKey: testGreetingFont,
                kVIPGreetingColorTemplateKey: testGreetingColor,
                kVIPSubscribeColorTemplateKey: testSubscribeColor,
                kVIPSubscribeTextTemplateKey: testSubscribeText,
                kVIPSubscribeFontTemplateKey: testSubscribeFont,
                kVIPBackgroundTemplateKey: testColorBackground
            ],
            dictionaryOfClassesByTemplateName: nil
        )
        let settings = VIPAppearanceSettings(dependencyManager: dependencyManager)

        XCTAssertEqual(testGreetingText, settings.greetingText)
        XCTAssertEqual(testGreetingFont, settings.greetingFont)
        XCTAssertEqual(testGreetingColor, settings.greetingColor)
        XCTAssertEqual(testSubscribeColor, settings.subscribeColor)
        XCTAssertEqual(testSubscribeText, settings.subscribeText)
        XCTAssertEqual(testSubscribeFont, settings.subscribeFont)
        XCTAssertEqual(testColorBackground.backgroundColor, settings.backgroundColor)
    }
}
