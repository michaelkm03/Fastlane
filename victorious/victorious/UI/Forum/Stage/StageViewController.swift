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
        static let contentHideAnimationDuration: NSTimeInterval = 0.5
        static let fixedStageHeight: CGFloat = 200.0
    }
    
    /// The content view that grows and shrinks depending on the content it is displaying.
    /// Is is also this size that will be broadcasted to the stage delegate.
    @IBOutlet private weak var mainContentView: UIView!
    @IBOutlet private weak var mainContentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var mediaContentView: MediaContentView!
    
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
        delegate?.stage(self, didUpdateContentHeight: Constants.fixedStageHeight)
    }

    func removeContent() {
        clearStageMedia()
    }

    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: Clear Media

    //TODO: Implement transition on media content view and call `delegate?.stage(self, didUpdateContentHeight: Constants.fixedStageHeight)`
    
    private func clearStageMedia(animated: Bool = false) {
        mediaContentView.videoCoordinator?.pauseVideo()
        mainContentViewBottomConstraint.constant = 0
        
        UIView.animateWithDuration(animated == true ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
        self.delegate?.stage(self, didUpdateContentHeight: 0.0)
    }
}
