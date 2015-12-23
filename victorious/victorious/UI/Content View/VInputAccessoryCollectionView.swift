//
//  VInputAccessoryCollectionView.swift
//  victorious
//
//  Created by Michael Sena on 7/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A `UICollectionView` subclass to provide hooks into the `UIResponder
/// inputAccessoryView` infrastructure.
class VInputAccessoryCollectionView: UICollectionView {
    
    /// The accessoryView to return as the collectionView's `inputAccessoryView`
    var accessoryView: UIView?
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
}
