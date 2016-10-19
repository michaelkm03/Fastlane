//
//  LinkLabel.swift
//  victorious
//
//  Created by Jarod Long on 9/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

/// A `UILabel` subclass that supports showing tappable links by using `LinkDetector`s.
class LinkLabel: UILabel, NSLayoutManagerDelegate {
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        textContainer.layoutManager = layoutManager
        isUserInteractionEnabled = true
    }
    
    // MARK: - Content
    
    override var text: String? {
        didSet {
            updateLinks()
        }
    }
    
    // MARK: - Appearance
    
    override var textColor: UIColor! {
        didSet {
            baseTextColor = textColor
            highlightLinks()
        }
    }
    
    /// The text color that should apply to the non-link portions of the text.
    ///
    /// We would ideally be able to use `textColor` directly, but for unknown reasons, sometimes that property will
    /// report the default black color rather than the color that was most recently set to it.
    ///
    private var baseTextColor = UIColor.black
    
    var highlightedLinkColor: UIColor?
    
    private var effectiveHighlightedLinkColor: UIColor {
        return highlightedLinkColor ?? tintColor.withAlphaComponent(0.5)
    }
    
    // MARK: - Links
    
    var linkDetectors = [LinkDetector]() {
        didSet {
            updateLinks()
        }
    }
    
    private var highlightedLink: Link? {
        didSet {
            if highlightedLink != oldValue {
                highlightLinks()
            }
        }
    }
    
    private var links = [Link]()
    
    private func updateLinks() {
        links = linkDetectors.flatMap { detector in
            detector.detectLinks(in: self.text ?? "").map { range in
                Link(range: range, callback: detector.callback)
            }
        }
        
        highlightLinks()
    }
    
    private func highlightLinks() {
        let text = self.text ?? ""
        let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
        
        for link in links {
            let range = NSRange(
                location: text.characters.distance(from: text.startIndex, to: link.range.lowerBound),
                length: text.characters.distance(from: link.range.lowerBound, to: link.range.upperBound)
            )
            
            if range.location + range.length > attributedString.length {
                continue
            }
            
            attributedString.setAttributes(highlightAttributes(highlighted: link == highlightedLink), range: range)
        }
        
        attributedText = attributedString
        textStorage.setAttributedString(attributedString)
    }
    
    private var baseAttributes: [String: AnyObject] {
        let mutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.alignment = textAlignment
        
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: baseTextColor,
            NSParagraphStyleAttributeName: mutableParagraphStyle
        ] as [String : Any]
        
        return attributes as [String : AnyObject]
    }
    
    private func highlightAttributes(highlighted: Bool) -> [String: AnyObject] {
        var attributes = baseAttributes
        attributes[NSForegroundColorAttributeName] = highlighted ? effectiveHighlightedLinkColor : tintColor
        return attributes
    }
    
    // MARK: - Text storage
    
    lazy var textContainer: NSTextContainer = {
        let _textContainer = NSTextContainer()
        _textContainer.lineFragmentPadding = 0.0
        _textContainer.maximumNumberOfLines = self.numberOfLines
        _textContainer.lineBreakMode = self.lineBreakMode
        _textContainer.size = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        return _textContainer
    }()
    
    lazy var layoutManager: NSLayoutManager = {
        let _layoutManager = NSLayoutManager()
        _layoutManager.delegate = self
        _layoutManager.addTextContainer(self.textContainer)
        return _layoutManager
    }()
    
    lazy var textStorage: NSTextStorage = {
        let _textStorage = NSTextStorage()
        _textStorage.addLayoutManager(self.layoutManager)
        return _textStorage
    }()
    
    private func updateTextContainerSize() {
        textContainer.size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
    }
    
    // MARK: - Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightedLink = getLink(for: touches)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightedLink = getLink(for: touches)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let highlightedLink = highlightedLink, let text = text {
            let matchedString = text.substring(with: highlightedLink.range)
            highlightedLink.callback?(matchedString)
        }
        
        highlightedLink = nil
        
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlightedLink = nil
        super.touchesCancelled(touches, with: event)
    }
    
    private func getLink(for touches: Set<UITouch>?) -> Link? {
        if let touch = touches?.first {
            return getLink(at: touch.location(in: self))
        }
        
        return nil
    }
    
    private func getLink(at location: CGPoint) -> Link? {
        let location = location + CGPoint(x: 0.0, y: -verticalOffsetToTopOfText)
        var fractionOfDistance = CGFloat(0.0)
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: &fractionOfDistance)
        
        guard characterIndex <= textStorage.length, let text = text else {
            return nil
        }
        
        for link in links {
            let rangeLocation = text.characters.distance(from: text.startIndex, to: link.range.lowerBound)
            let rangeLength = text.characters.distance(from: link.range.lowerBound, to: link.range.upperBound)
            
            if rangeLocation <= characterIndex && (rangeLocation + rangeLength - 1) >= characterIndex {
                let glyphRange = layoutManager.glyphRange(forCharacterRange: NSMakeRange(rangeLocation, rangeLength), actualCharacterRange: nil)
                let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                
                if boundingRect.contains(location) {
                    return link
                }
            }
        }
        
        return nil
    }
    
    /// Returns the offset from the top of the label's bounds to the top of its text.
    private var verticalOffsetToTopOfText: CGFloat {
        // To get the offset, we need to know the size of the text, which requires setting the preferred max layout
        // width. We don't want to actually change that value though, so we restore it when we're done.
        let oldPreferredMaxLayoutWidth = preferredMaxLayoutWidth
        preferredMaxLayoutWidth = frame.width
        let naturalSize = intrinsicContentSize
        preferredMaxLayoutWidth = oldPreferredMaxLayoutWidth
        return (frame.height - naturalSize.height) / 2.0
    }
    
    // MARK: - Layout
    
    override var frame: CGRect {
        didSet {
            updateTextContainerSize()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            updateTextContainerSize()
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            textContainer.maximumNumberOfLines = numberOfLines
        }
    }
    
    override var lineBreakMode: NSLineBreakMode {
        didSet {
            textContainer.lineBreakMode = lineBreakMode
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTextContainerSize()
    }
}

private struct Link: Equatable {
    var range: Range<String.Index>
    var callback: ((_ matchedString: String) -> Void)?
}

private func ==(link1: Link, link2: Link) -> Bool {
    return link1.range == link2.range
}
