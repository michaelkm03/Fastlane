//
//  VDependencyManager+SystemFontTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import victorious

private let fontKey = "font"

class VDependencyManager_SystemFontTests: XCTestCase {
    
    let fontSize: Float = 10
    
    private func dependencyManagerWithFontNamed(name: String) -> VDependencyManager {
        let configuration = [
            fontKey : [
                "fontSize": NSNumber(float: self.fontSize),
                "fontName": name
            ]
        ]
        return VDependencyManager(parentManager: nil, configuration: configuration, dictionaryOfClassesByTemplateName: nil)
    }

    func testSystemFonts() {
        var dependencyManager = dependencyManagerWithFontNamed("systemFont-Light")
        XCTAssertEqual(dependencyManager.font, UIFont.systemFontOfSize(CGFloat(fontSize), weight: UIFontWeightLight))
        
        dependencyManager = dependencyManagerWithFontNamed("systemFont-Regular")
        XCTAssertEqual(dependencyManager.font, UIFont.systemFontOfSize(CGFloat(fontSize), weight: UIFontWeightRegular))
        
        dependencyManager = dependencyManagerWithFontNamed("systemFont-Medium")
        XCTAssertEqual(dependencyManager.font, UIFont.systemFontOfSize(CGFloat(fontSize), weight: UIFontWeightMedium))
        
        dependencyManager = dependencyManagerWithFontNamed("systemFont-Bold")
        XCTAssertEqual(dependencyManager.font, UIFont.systemFontOfSize(CGFloat(fontSize), weight: UIFontWeightBold))
        
        dependencyManager = dependencyManagerWithFontNamed("systemFont-TotallyRidiculousValueThatShouldMakeTheDefaultAppear")
        XCTAssertEqual(dependencyManager.font, UIFont.systemFontOfSize(CGFloat(fontSize), weight: UIFontWeightRegular))
    }
}

private extension VDependencyManager {
    
    var font: UIFont {
        return fontForKey(fontKey)
    }
}
