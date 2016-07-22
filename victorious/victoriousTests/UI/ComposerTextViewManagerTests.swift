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
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .redColor()
        textView.font = UIFont.systemFontOfSize(10)
        return textView
    }()

    func testDefaultInitializerValues() {
        
        guard let manager = ComposerTextViewManager(textView: textView) else {
            XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
            return
        }
        XCTAssertEqual(manager.maximumTextLength, 0)
        XCTAssertTrue(manager.dismissOnReturn)
        XCTAssertNil(manager.delegate)
    }
    
    func testSetsTextViewDelegate() {
        
        guard let manager = ComposerTextViewManager(textView: textView),
            let delegate = textView.delegate as? ComposerTextViewManager else {
                XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
                return
        }
        XCTAssertEqual(delegate, manager)
    }
    
    func testCanUpdateTextView() {
        
        let baseText = "string"
        let additionalText = "!" // Must be of length 1
        let baseTextLength = baseText.characters.count
        let additionalTextLength = additionalText.characters.count
        textView.text = baseText
        guard let manager = ComposerTextViewManager(textView: textView, delegate: nil, maximumTextLength: baseTextLength) else {
            XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
            return
        }
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
        guard let _ = ComposerTextViewManager(textView: textView, delegate: delegate) else {
            XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
            return
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testDismissOnReturn() {
        
        guard var manager = ComposerTextViewManager(textView: textView, delegate: nil, maximumTextLength: 0, dismissOnReturn: true) else {
            XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
            return
        }
        XCTAssertFalse(manager.shouldDismissForText("a"))
        XCTAssertTrue(manager.shouldDismissForText("\n"))
        
        guard let updatedManager = ComposerTextViewManager(textView: textView, delegate: nil, maximumTextLength: 0, dismissOnReturn: false) else {
            XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
            return
        }
        manager = updatedManager
        XCTAssertFalse(manager.shouldDismissForText("a"))
        XCTAssertFalse(manager.shouldDismissForText("\n"))
    }
    
    func testAppendIfPossible() {
        
        guard let manager = ComposerTextViewManager(textView: textView, delegate: nil, maximumTextLength: 10, dismissOnReturn: true) else {
            XCTFail("Failed to create ComposerTextViewManager for textView \(textView)")
            return
        }
        textView.text = "0123456789" // Fill up text view with text
        XCTAssertFalse(manager.appendTextIfPossible(textView, text: "a"))
        
        textView.text = "012345678" // One available spot before hitting max length
        XCTAssertTrue(manager.appendTextIfPossible(textView, text: "9"))
        XCTAssertEqual(textView.text, "0123456789")
        XCTAssertFalse(manager.appendTextIfPossible(textView, text: "a"))
    }
    
    // MARK: - Delegate stub
    
    private class ComposerTextViewManagerDelegateStub: ComposerTextViewManagerDelegate {
        
        var onSetTextViewContentSize: (Void -> ())? = nil
        
        var onSetTextViewHasText: (Void -> ())? = nil
        
        var onSetTextViewIsEditing: (Void -> ())? = nil
        
        var onSetTextViewPrependedImage: (Void -> ())? = nil
        
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
        
        var textViewIsEditing: Bool = false {
            didSet {
                onSetTextViewIsEditing?()
            }
        }
        
        private var textViewPrependedImage: UIImage? {
            didSet {
                onSetTextViewPrependedImage?()
            }
        }
        
        var textViewCurrentHashtag: (String, NSRange)?
        
        func textViewDidHitCharacterLimit(textView: UITextView) {}
        
        var textViewCanDismiss: Bool = true
        
        func inputTextAttributes() -> (inputTextColor: UIColor?, inputTextFont: UIFont?) {
            return (nil, nil)
        }
    }
}
