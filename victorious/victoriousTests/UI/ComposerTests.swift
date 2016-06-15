//
//  ComposerTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

//MAKE COMPOSER VIEW CONTROLLER INIT IN EXTENSION, SEND FROM THERE

class ComposerTests: XCTestCase {
    func testSendWithImage() {
        let imageText = "\u{ef}"
        let newLine = "\n"
        let text = "test"
        
        let expectation = expectationWithDescription("sent event")
        ComposerViewController.onSend = { event in
            expectation.fulfill()
            switch event {
                case .sendContent(let content):
                    XCTAssertEqual(content.text, text)
                default:
                    XCTFail("test was setup incorrectly, did not recieve a send content message")
            }
        }
        
        let asset = ContentMediaAsset(contentType: .image, url: NSURL())!
        ComposerViewController.newComposerViewController().sendMessage(asset: asset, text: imageText + newLine + text, currentUser: User(id: 0))
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}

private extension ComposerViewController {
    static var onSend: (ForumEvent -> ())?
    
    static func newComposerViewController() -> ComposerViewController {
        return ComposerViewController.v_initialViewControllerFromStoryboard("Composer")
    }
}

extension ForumEventSender {
    func send(event: ForumEvent) {
        ComposerViewController.onSend?(event)
    }
}
