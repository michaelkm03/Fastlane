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
        
        let imageContent = Content(id: "1", createdAt: NSDate(), type: .image, text: "1", assets:       [ContentMediaAsset(contentType: .image, url: NSURL(string: "http://www.w3schools.com/css/trolltunga.jpg")!)!], author: User(id: 1))
        self.addContent(imageContent)
        
        dispatch_after(3) {
            let imageContent = Content(id: "1", createdAt: NSDate(), type: .image, text: "1", assets: [ContentMediaAsset(contentType: .image, url: NSURL(string: "https://newevolutiondesigns.com/images/freebies/cool-iphone-wallpaper-1.jpg")!)!], author: User(id: 1))
            self.addContent(imageContent)
        }
        
        dispatch_after(6) {
            let imageContent = Content(id: "1", createdAt: NSDate(), type: .image, text: "1", assets: [ContentMediaAsset(contentType: .image, url: NSURL(string: "http://media2.popsugar-assets.com/files/thumbor/Pn_lLpOa4pBvH6orCLvJcuMi6b8=/fit-in/1024x1024/2015/06/16/763/n/1922507/f703b42c_edit_img_image_3125473_1434372300_Daisies/i/iPhone-Wallpaper.jpg")!)!], author: User(id: 1))
            self.addContent(imageContent)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        hideStage()
    }
    
    //MARK: - Stage
    
    func addContent(stageContent: ContentModel) {
        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.updateContent(stageContent, isVideoToolBarAllowed: false)
        
        let defaultStageHeight = view.bounds.width / Constants.defaultAspectRatio
        delegate?.stage(self, didUpdateContentHeight: defaultStageHeight)
    }

    func removeContent() {
        hideStage()
    }

    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: Clear Media
    
    private func hideStage(animated: Bool = false) {
        mediaContentView.videoCoordinator?.pauseVideo()
        
        UIView.animateWithDuration(animated == true ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
        self.delegate?.stage(self, didUpdateContentHeight: 0.0)
    }
}
