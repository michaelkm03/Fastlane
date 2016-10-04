//
//  ComposerTextViewManagerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerTextViewManagerDelegate: class {
    var textViewContentSize: CGSize { get set }
    
    var textViewHasText: Bool { get set }
    
    var textViewIsEditing: Bool { get set }
    
    var textViewPrependedImage: UIImage? { get set }
    
    var textViewHasPrependedImage: Bool { get }
    
    var textViewCanDismiss: Bool { get }
    
    var textViewCurrentHashtag: (String, NSRange)? { get set }

    func textViewDidHitCharacterLimit(_ textView: UITextView)
    
    func inputTextAttributes() -> (inputTextColor: UIColor?, inputTextFont: UIFont?)
}

extension ComposerTextViewManagerDelegate {
    var textViewHasPrependedImage: Bool {
        return textViewPrependedImage != nil
    }
}
