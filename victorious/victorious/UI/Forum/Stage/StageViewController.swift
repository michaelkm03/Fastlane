//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import SDWebImage

class StageViewController: UIViewController, Stage, VVideoPlayerDelegate {
    
    private struct Constants {
        static let contentSizeAnimationDuration: NSTimeInterval = 0.5
        static let maximumStageHeight: CGFloat = 200.0
    }
    
    @IBOutlet private var mediaContentView: MediaContentView!
    
    private var currentContentView: UIView?
    
    private var stageDataSource: StageDataSource?
    
    weak var delegate: StageDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }

    // MARK: Life cycle
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mediaContentView.videoCoordinator?.playVideo()
    }

    override func viewWillDisappear(animated: Bool) {
        clearStageMedia()
    }

    //MARK: - Stage
    
    func addContent(stageContent: ContentModel) {
        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.updateContent(stageContent, isVideoToolBarAllowed: false)
        
        reportHeightChange(for: stageContent)
    }

    func removeContent() {
        clearStageMedia()
    }

    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: Clear Media
    
    private func clearStageMedia(animated: Bool = false) {
        mediaContentView.videoCoordinator?.pauseVideo()
        
        UIView.animateWithDuration(animated == true ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
        self.delegate?.stage(self, didUpdateContentHeight: 0.0)
    }
    
    // MARK: - Report Height Change
    
    private func reportHeightChange(for content: ContentModel) {
        let contentHeight = content.previewImageSize?.height ?? Constants.maximumStageHeight
        let clampedHeight = min(max(contentHeight, 0.0), Constants.maximumStageHeight)
        
        delegate?.stage(self, didUpdateContentHeight: clampedHeight)
    }
}
