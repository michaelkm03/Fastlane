//
//  Composer.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Composer: class {
    
    /// The maximum height of the composer. Triggers a UI update if the composer
    /// could be updated to better represent its content inside a frame with the new height.
    var maximumTextInputHeight: CGFloat { get set }
    
    weak var delegate: ComposerDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    func dismissKeyboard(animated: Bool)
}

/// Conformers will recieve messages when a composer's buttons are pressed and when
/// a composer changes its height.
protocol ComposerDelegate: class {
    
    func composer(composer: Composer, didSelectCreationFlowType creationFlowType: VCreationFlowType)
    
    func composer(composer: Composer, didConfirmWithMedia media: MediaAttachment?, caption: String?)
    
    /// Called when the composer updates to a new height. The returned value represents
    /// the total height of the composer content (including the keyboard) and can be more
    /// than the composer's maximumHeight.
    func composer(composer: Composer, didUpdateContentHeight height: CGFloat)
}

