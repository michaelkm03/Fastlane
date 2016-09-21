//
//  ComposerViewControllerTests.swift
//  victorious
//
//  Created by Jarod Long on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class ComposerViewControllerTests: XCTestCase {
    let viewController = UIStoryboard(name: "Composer", bundle: nil).instantiateInitialViewController() as! ComposerViewController
    
    override func setUp() {
        super.setUp()
        
        viewController.dependencyManager = VDependencyManager(dictionary: [
            VDependencyManagerMainTextColorKey: [
                "red": 255,
                "green": 255,
                "blue": 255,
                "alpha": 230
            ],
            VDependencyManagerParagraphFontKey: [
                "fontName": "systemFont-Light",
                "fontSize": 18
            ]
        ])
        
        viewController.loadViewIfNeeded()
    }
    
    func testAppend() {
        XCTAssertEqual(viewController.text, "")
        
        viewController.append("@someuser")
        XCTAssertEqual(viewController.text, "@someuser ")
        
        viewController.append("@anotheruser")
        XCTAssertEqual(viewController.text, "@someuser @anotheruser ")
        
        viewController.text = "here's some text"
        viewController.append("@thirduser")
        XCTAssertEqual(viewController.text, "here's some text @thirduser ")
    }
}
