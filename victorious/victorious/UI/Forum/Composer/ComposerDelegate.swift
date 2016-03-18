//
//  ComposerControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Conformers will recieve messages when a composer's buttons are pressed and when
/// a composer changes its height.
protocol ComposerDelegate: class {
    
    func composer(composer: Composer, didSelectCreationType creationType: VCreationType)
    
    func composer(composer: Composer, confirmedWithMedia media: MediaAttachment, caption: String?)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer content (including the keyboard) and can be more
    /// than the composer's maximumHeight.
    func composer(composer: Composer, didUpdateToContentHeight height: CGFloat)
}
