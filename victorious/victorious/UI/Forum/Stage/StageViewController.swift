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
        static let defaultAspectRatio: CGFloat = 16 / 9
        
        static let pillInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        static let pillHeight: CGFloat = 30
        static let pillBottomMargin: CGFloat = 20
    }
    
    @IBOutlet private var mediaContentView: MediaContentView!
    private lazy var newItemPill: TextOnColorButton? = { [weak self] in
        guard let pillDependency = self?.dependencyManager.newItemButtonDependency else {
            return nil
        }
        let pill = TextOnColorButton()
        pill.dependencyManager = pillDependency
        pill.contentEdgeInsets = Constants.pillInsets
        pill.sizeToFit()
        pill.clipsToBounds = true
        pill.hidden = true
        
        if let strongSelf = self {
            pill.addTarget(strongSelf, action: #selector(onPillSelect), forControlEvents: .TouchUpInside)
        }
        
        return pill
    }()
    
    private var hasShownStage: Bool = false
    private var queuedContent: ContentModel?
    
    private var stageDataSource: StageDataSource?
    
    weak var delegate: StageDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }
    
    override func viewDidLoad() {
        guard let newItemPill = newItemPill else {
            return
        }
        view.addSubview(newItemPill)
        view.v_addPinToBottomToSubview(newItemPill, bottomMargin: Constants.pillBottomMargin)
        view.v_addCenterHorizontallyConstraintsToSubview(newItemPill)
        newItemPill.v_addHeightConstraint(Constants.pillHeight)
    }

    // MARK: Life cycle
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mediaContentView.allowsVideoControls = false
        mediaContentView.videoCoordinator?.playVideo()
    }

    override func viewWillDisappear(animated: Bool) {
        hideStage()
    }
    
    //MARK: - Stage
    
    func addContent(stageContent: ContentModel) {
        queuedContent = stageContent
        if !hasShownStage || mediaContentView.content?.type != .video || newItemPill == nil {
            // If the stage was not shown, 
            // or if the current content was one that is not time based (video for now),
            // or if we don't have a pill (for VIP stage)
            // we will immediately move to the next content.
            hasShownStage = true
            let defaultStageHeight = view.bounds.width / Constants.defaultAspectRatio
            delegate?.stage(self, didUpdateContentHeight: defaultStageHeight)
            nextContent()
        }
        else {
            showPill()
        }
    }
    
    func nextContent() {
        hidePill()
        guard let stageContent = queuedContent else {
            return
        }
        
        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.content = stageContent
        queuedContent = nil
    }
    
    func onPillSelect() {
        nextContent()
        hidePill()
    }

    func removeContent() {
        hidePill()
        hideStage()
        hasShownStage = false
        queuedContent = nil
    }
    
    private func hidePill() {
        guard
            let newItemPill = newItemPill
            where newItemPill.hidden == false
        else {
            return
        }
        
        UIView.animateWithDuration(0.5, animations: {
            newItemPill.alpha = 0.0
        }) { _ in
            newItemPill.hidden = true
        }
    }
    
    private func showPill() {
        guard
            let newItemPill = newItemPill
            where newItemPill.hidden == true
        else {
            return
        }
        
        newItemPill.alpha = 0.0
        newItemPill.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            newItemPill.alpha = 1.0
        })
    }

    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: Clear Media
    
    private func hideStage(animated: Bool = false) {
        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.hideContent(animated: animated)
        
        UIView.animateWithDuration(animated == true ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
        self.delegate?.stage(self, didUpdateContentHeight: 0.0)
    }
}

private extension VDependencyManager {
    var newItemButtonDependency: VDependencyManager? {
        return childDependencyForKey("newItemButton")
    }
}
