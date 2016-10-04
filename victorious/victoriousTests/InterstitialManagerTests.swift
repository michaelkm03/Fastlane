//
//  InterstitialManagerTests.swift
//  victorious
//
//  Created by Tian Lan on 4/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
@testable import VictoriousIOSSDK

class InterstitialManagerTests: XCTestCase {
    
    fileprivate var interstitialManager: InterstitialManager!
    fileprivate var interstitialListener: MockInterstitialListener!
    fileprivate var showNextInterstitial: (() -> Bool)!
    
    fileprivate let alertA = Alert(title: "a", description: "a")
    fileprivate let alertB = Alert(title: "b", description: "b")
    fileprivate let alertC = Alert(title: "c", description: "c")
    
    override func setUp() {
        interstitialManager = InterstitialManager()
        interstitialListener = MockInterstitialListener()
        interstitialManager.interstitialListener = interstitialListener
        showNextInterstitial = { [unowned self] in
            self.interstitialManager.showNextInterstitial(onViewController: UIViewController())
        }
    }
    
    func testReceivingAlerts() {
        interstitialManager.receive([alertA, alertB, alertC])
        XCTAssertEqual(interstitialListener.registeredInterstitialsCount, 3)
        interstitialManager.receive(alertA)
        XCTAssertEqual(interstitialListener.registeredInterstitialsCount, 3)
    }
    
    func testDismissingAlerts() {
        interstitialManager.dismissInterstitial(UIViewController())
        XCTAssertFalse(interstitialManager.isShowingInterstital)
    }
    
    func testClearAllAlerts() {
        interstitialManager.receive([alertA, alertB, alertC])
        XCTAssertTrue(showNextInterstitial())
        interstitialManager.clearAllRegisteredAlerts()
        XCTAssertFalse(showNextInterstitial())
    }
    
    func testShowInterstitial() {
        XCTAssertFalse(showNextInterstitial())
        interstitialManager.receive([alertA])
        XCTAssertTrue(showNextInterstitial())
    }
}

class MockInterstitialListener: NSObject, InterstitialListener {
    fileprivate(set) var registeredInterstitialsCount: Int = 0
    
    func newInterstitialHasBeenRegistered() {
        registeredInterstitialsCount += 1
    }
}
