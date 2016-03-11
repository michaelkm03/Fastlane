//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ChatFeedViewController: UIViewController, ChatFeed {
    
    var dependencyManager: VDependencyManager! {
        didSet {
            
        }
    }
    
    //MARK: - ChatFeed
    
    func setFeedEdgeInsets(insets: UIEdgeInsets, animated: Bool) {
        
    }
    
    weak var delegate: ChatFeedDelegate?
}
