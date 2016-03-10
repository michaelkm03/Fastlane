//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class StageViewController: UIViewController, Stage {
    
    /// The content view that is grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadbasted
    @IBOutlet private weak var mainContentView: UIView!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var videoContainerView: UIView!
    
    private var currentStagedMedia: Stageable?
    
    private var dependencyManager: VDependencyManager!
    
    class func new(dependencyManager dependencyManager: VDependencyManager) -> StageViewController {
        //TODO: Load from storyboard
        let stageVC = StageViewController()
        stageVC.dependencyManager = dependencyManager
        return stageVC
    }
    
    
    //MARK: - Stage
    
    weak var delegate: StageDelegate?
    
    func startPlayingMedia(media: Stageable) {
        switch media.stageMediaType {
        case .Image:
            print("will add image to stage")
        case .Video:
            print("will add video to stage")
        case .Gif:
            print("will add gif to stage")
        case .Empty:
            print("will remove current staged media and possibly hide tha stage")
        }
        
//        delegate?.didUpdateWithMed
    }
    
    func stopPlayingMedia() {
        
    }
    
    
    // MARK: - Private
    
    private func clearStageMedia() {
        
    }
}
