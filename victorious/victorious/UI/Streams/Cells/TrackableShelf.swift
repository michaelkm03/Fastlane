//
//  TrackableShelf.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Objects conforming to this protocol will perform the
/// tracking of sequences displayed within them.
@objc protocol TrackableShelf {
    
    /// Sends off tracking events for sequences
    /// being displayed by this object.
    func trackVisibleSequences()
    
}