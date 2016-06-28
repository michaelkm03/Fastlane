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
    
    private var interstitialManager: InterstitialManager!
    private var interstitialListener: MockInterstitialListener!
    private var showNextInterstitial: (() -> Bool)!
    
    private let alertA = Alert(title: "a", description: "a")
    private let alertB = Alert(title: "b", description: "b")
    private let alertC = Alert(title: "c", description: "c")
    
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
    private(set) var registeredInterstitialsCount: Int = 0
    
    func newInterstitialHasBeenRegistered() {
        registeredInterstitialsCount += 1
    }
}
