//
//  CloseUpContainerViewController.swift
//  victorious
//
//  Created by Vincent Ho on 5/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class CloseUpContainerViewController: UIViewController, CloseUpViewDelegate {
    
    private let gridStreamController: GridStreamViewController<CloseUpView>

    init(dependencyManager: VDependencyManager, content: VContent? = nil, streamAPIPath: String?) {

        let header = CloseUpView.newWithDependencyManager(dependencyManager)
                
        let configuration = GridStreamConfiguration(
            sectionInset: UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0),
            interItemSpacing: CGFloat(3),
            cellsPerRow: 3,
            allowsForRefresh: false,
            managesBackground: true
        )
        
        gridStreamController = GridStreamViewController<CloseUpView>.newWithDependencyManager(
            dependencyManager,
            header: header,
            content: content,
            configuration: configuration,
            streamAPIPath: streamAPIPath
        )
        
        super.init(nibName: nil, bundle: nil)
        
        header.delegate = self
                
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraintsToSubview(gridStreamController.view)
        gridStreamController.didMoveToParentViewController(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    func updateContent(content: VContent) {
        gridStreamController.content = content
    }
    
    // MARK: - CloseUpViewDelegate
    
    func didSelectProfile() {
        
    }

}
