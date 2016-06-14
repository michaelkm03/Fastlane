//
//  ComposerTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ComposerTests: XCTestCase {
    let composerStub = ComposerStub()
    
    override func setUp() {
        super.setUp()
        AnonymousLoginOperation().queue()
    }
    
    func testSendWithImage() {
        let imageText = "\u{ef}"
        let newLine = "\n"
        let text = "test"
        
        let expectation = expectationWithDescription("sent event")
        composerStub.onSend = { event in
            expectation.fulfill()
            switch event {
                case .sendContent(let content):
                    XCTAssertEqual(content.text, imageText + text)
                default:
                    XCTFail("test was setup incorrectly, did not recieve a send content message")
            }
        }
        
        let asset = ContentMediaAsset(contentType: .image, url: NSURL())!
        composerStub.sendMessage(asset: asset, text: imageText + newLine + text, currentUser: User(id: 0))
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}

class ComposerStub: Composer {
    
    var onSend: (ForumEvent -> ())?
    
    func send(event: ForumEvent) {
        onSend?(event)
    }
    
    //MARK: Protocol conformance
    
    var maximumTextInputHeight: CGFloat = 0
    
    var creationFlowPresenter: VCreationFlowPresenter!
    
    weak var delegate: ComposerDelegate?
    
    var dependencyManager: VDependencyManager!
    
    func dismissKeyboard(animated: Bool) {}
        
    func setComposerVisible(visible: Bool, animated: Bool) {}
    
    weak var nextSender: ForumEventSender?
    
    func composerAttachmentTabBar(composerAttachmentTabBar: ComposerAttachmentTabBar, didSelectNavigationItem navigationItem: VNavigationMenuItem) {}
}
