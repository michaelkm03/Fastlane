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
    var maximumHeight: CGFloat { get set }
    
    weak var delegate: ComposerDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
}
