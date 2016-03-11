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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.v_colorFromHexString("170724")
    }
    
    //MARK: - StageController
    
    weak var delegate: StageDelegate?
    
    func startPlayingMedia(media: VAsset) {
        
    }
    
    func stopPlayingContent() {
        
    }
}