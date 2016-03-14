//
//  ComposerTextViewManagerTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class ComposerTextViewManagerTests: XCTestCase {
    
    let textView = UITextView()

    func testDefaultInitializerValues() {
        
        let manager = ComposerTextViewManager(textView: textView)
        XCTAssertEqual(manager.maximumTextLength, 0)
        XCTAssertEqual(manager.dismissalStrings, ["\n"])
        XCTAssertNil(manager.delegate)
    }
    
    func testSetsTextViewDelegate() {
        
        let manager = ComposerTextViewManager(textView: textView)
        guard let delegate = textView.delegate as? ComposerTextViewManager else {
            XCTFail()
            return
        }
        XCTAssertEqual(delegate, manager)
    }
    
    func testCanUpdateTextView() {
        
        let baseText = "string"
        let additionalText = "!" //Must be of length 1
        let baseTextLength = baseText.characters.count
        let additionalTextLength = additionalText.characters.count
        textView.text = baseText
        let manager = ComposerTextViewManager(textView: textView, delegate: nil, maximumTextLength: baseTextLength)
        XCTAssertFalse(manager.canUpdateTextView(textView, textInRange: NSRange(location: baseTextLength, length: 0), replacementText: additionalText))
        XCTAssertTrue(manager.canUpdateTextView(textView, textInRange: NSRange(location: baseTextLength - additionalTextLength, length: additionalTextLength), replacementText: additionalText))
        XCTAssertTrue(manager.canUpdateTextView(textView, textInRange: NSRange(location: baseTextLength - additionalTextLength, length: additionalTextLength), replacementText: ""))
        
        textView.text = baseText.substringToIndex(baseText.characters.indexOf(baseText.characters.last!)!)
        XCTAssertTrue(manager.canUpdateTextView(textView, textInRange: NSRange(location: baseTextLength, length: 0), replacementText: additionalText))
    }
    
    func testUpdateDelegate() {
        
        let delegate = ComposerTextViewManagerDelegateStub()
        let contentSizeExpectation = expectationWithDescription("Updated content size")
        delegate.onSetTextViewContentSize = {
            contentSizeExpectation.fulfill()
        }
        let textViewHasTextExpectation = expectationWithDescription("Updated text view has text")
        delegate.onSetTextViewHasText = {
            textViewHasTextExpectation.fulfill()
        }
        let manager = ComposerTextViewManager(textView: textView, delegate: delegate)
        manager.updateDelegateOfTextViewStatus(textView)
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    
    //MARK: - Delegate stub
    
    private class ComposerTextViewManagerDelegateStub: ComposerTextViewManagerDelegate {
        
        var onSetTextViewContentSize: (Void -> ())? = nil
        
        var onSetTextViewHasText: (Void -> ())? = nil
        
        var textViewContentSize: CGSize = CGSize.zero {
            didSet {
                onSetTextViewContentSize?()
            }
        }
        
        var textViewHasText: Bool = false {
            didSet {
                onSetTextViewHasText?()
            }
        }
    }
}
