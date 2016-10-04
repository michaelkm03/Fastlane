//
//  ComposerAttachmentTabBarButtonTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ComposerAttachmentTabBarButtonTests: XCTestCase {

    func testValuesAfterInit() {
        
        guard let icon = UIImage(named: "sampleImage", in: Bundle(for: MediaSearchMediaExporterTests.self), compatibleWith: nil) else {
            XCTFail("sampleImage was removed from the test data folder")
            return
        }
        
        let navigationMenuItem = VNavigationMenuItem(title: "title", identifier: "identifier", icon: icon, selectedIcon: UIImage(), destination: "testing", position: "top", tintColor: UIColor.red)
        let button = ComposerAttachmentTabBarButton(navigationMenuItem: navigationMenuItem)
        XCTAssertEqual(button.navigationMenuItem, navigationMenuItem)
        XCTAssertEqual(button.image(for: .normal), icon)
    }
}
