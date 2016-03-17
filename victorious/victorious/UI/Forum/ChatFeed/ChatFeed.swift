//
//  ChatFeed.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ChatFeed: class {
    
    weak var delegate: ChatFeedDelegate? { get set }
    
    var dependencyManager: VDependencyManager! { get set }
    
    func setEdgeInsets(insets: UIEdgeInsets)
}
