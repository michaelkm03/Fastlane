//
//  ChatFeedViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ChatFeedViewController: UIViewController, ChatFeed {
    
    private enum MessageDisplayState {
        case Expanded, Collapsed
    }
    
    private var messages = [VMessage : MessageDisplayState]()
    
    private var maximumMessageLines = 0
    
    private var dependencyManager: VDependencyManager! {
        didSet {
            if let maximumMessageLines = dependencyManager.maximumMessageLines {
                self.maximumMessageLines = maximumMessageLines
            }
        }
    }
    
    class func new( dependencyManager dependencyManager: VDependencyManager ) -> ChatFeedViewController {
        
        //Load from storyboard
        let chatFeedVC = ChatFeedViewController()
        chatFeedVC.dependencyManager = dependencyManager
        return chatFeedVC
    }
    
    
    //MARK: - ChatFeedController
    
    weak var delegate: ChatFeedDelegate?
    
    func setFeedEdgeInsets(insets: UIEdgeInsets, animated: Bool = true) {
        
    }
    
    func addMessages(messages: [VMessage], animated: Bool = true) {
        
    }
}

private extension VDependencyManager {
    
    var maximumMessageLines: Int? {
        return nil
    }
}
