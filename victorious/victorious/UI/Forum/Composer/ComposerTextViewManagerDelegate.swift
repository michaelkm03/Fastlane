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
    
    var textViewCanDismiss: Bool { get }
}
