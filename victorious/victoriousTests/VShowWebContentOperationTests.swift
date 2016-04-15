//
//  VShowWebContentOperationTests.swift
//  victorious
//
//  Created by Jarod Long on 4/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class VShowWebContentOperationTests: BasePersistentStoreTestCase {
    let window = UIWindow()
    let presentingViewController = UIViewController()
    
    private func runOperation(rootViewController rootViewController: UIViewController, title: String, forceModal: Bool) {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        
        let operation = ShowWebContentOperation(
            originViewController: presentingViewController,
            title: title,
            createFetchOperation: { MockFetchWebContentOperation() },
            forceModal: forceModal,
            animated: false
        )
        
        operation.start()
    }
    
    func testPushesToNavigationController() {
        let navigationController = UINavigationController(rootViewController: presentingViewController)
        
        runOperation(
            rootViewController: navigationController,
            title: "Navigation Web Content",
            forceModal: false
        )
        
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertEqual(navigationController.viewControllers.first, presentingViewController)
        XCTAssert(navigationController.viewControllers.last is VWebContentViewController)
        XCTAssertEqual(navigationController.viewControllers.last?.title, "Navigation Web Content")
    }
    
    func testPresentsModally() {
        runOperation(
            rootViewController: presentingViewController,
            title: "Modal Web Content",
            forceModal: false
        )
        
        guard let navigationController = presentingViewController.presentedViewController as? UINavigationController else {
            XCTFail("ShowWebContentOperation failed to present a navigation controller.")
            return
        }
        
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssert(navigationController.viewControllers.first is VWebContentViewController)
        XCTAssertEqual(navigationController.viewControllers.first?.title, "Modal Web Content")
    }
    
    func testForceModal() {
        let rootNavigationController = UINavigationController(rootViewController: presentingViewController)
        
        runOperation(
            rootViewController: rootNavigationController,
            title: "Forced Modal Web Content",
            forceModal: true
        )
        
        guard let presentedNavigationController = presentingViewController.presentedViewController as? UINavigationController else {
            XCTFail("ShowWebContentOperation failed to present a navigation controller.")
            return
        }
        
        XCTAssertEqual(presentedNavigationController.viewControllers.count, 1)
        XCTAssert(presentedNavigationController.viewControllers.first is VWebContentViewController)
        XCTAssertEqual(presentedNavigationController.viewControllers.first?.title, "Forced Modal Web Content")
    }
}

private class MockFetchWebContentOperation: FetchWebContentOperation {
    private override var publicBaseURL: NSURL {
        return NSURL(string: "http://apple.com")!
    }
    
    override func main() {
        resultHTMLString = "<p>yo</p>"
    }
}
