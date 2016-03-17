//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class StageViewController: UIViewController, Stage {
    
    var dependencyManager: VDependencyManager!
    
    weak var delegate: StageDelegate?
    
    // MARK: - UIViewController overrides
    
    override func viewWillAppear(animated: Bool) {
        let randomContentHeight = CGFloat(20 + arc4random() % 40)
        let size = CGSize(width: view.bounds.width, height: randomContentHeight)
        delegate?.stage(self, didUpdateContentSize: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.v_colorFromHexString("170724")
    }
    
    // MARK: - ForumEventReceiver {
    
    func receiveEvent(event: ForumEvent) {
        
    }
    
    //MARK: - StageController
    
    func startPlayingMedia(media: VAsset) {
        
    }
    
    func stopPlayingContent() {
        
    }
}