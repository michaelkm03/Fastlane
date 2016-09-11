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
    
    func new(dependencyManager: VDependencyManager) {
        
    }
    
    //MARK: MediaSearchDelegate
    
    func mediaSearchDidCancel() {
        
    }
    
    func mediaSearchResultSelected(selectedMediaSearchResult: MediaSearchResult) {
        
    }
}
