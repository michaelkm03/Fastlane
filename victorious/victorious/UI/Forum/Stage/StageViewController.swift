//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class StageViewController: UIViewController, Stage {
    
    private var dependencyManager: VDependencyManager!
    
    class func new( dependencyManager dependencyManager: VDependencyManager ) -> StageViewController {
        
        let stageVC = StageViewController()
        stageVC.dependencyManager = dependencyManager
        return stageVC
    }
    
    
    //MARK: - StageController
    
    weak var delegate: StageDelegate?
    
    func startPlayingMedia(media: VAsset) {
        
    }
    
    func stopPlayingContent() {
        
    }
}