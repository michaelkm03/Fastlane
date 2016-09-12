//
//  StickerCreationFlowController.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StickerCreationFlowController: UIViewController, MediaSearchDelegate {
    
    private(set) var dependencyManager: VDependencyManager!
    
    lazy var  mediaSearchViewController: MediaSearchViewController = {
        let dataSource = StickerSearchDataSource()
        let mediaSearchViewController = MediaSearchViewController.mediaSearchViewController(dataSource: dataSource, dependencyManager: self.dependencyManager)
        mediaSearchViewController.delegate = self
        return mediaSearchViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .redColor()
    }
    
    static func new(dependencyManager: VDependencyManager) -> StickerCreationFlowController {
        return StickerCreationFlowController()
    }
    
    //MARK: MediaSearchDelegate
    
    func mediaSearchDidCancel() {
        
    }
    
    func mediaSearchResultSelected(selectedMediaSearchResult: MediaSearchResult) {
        
    }
}
