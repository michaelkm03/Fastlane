//
//  TutorialViewController.swift
//  victorious
//
//  Created by Tian Lan on 4/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UICollectionViewDelegate, TutotrialCollectionViewDataSourceDelegate {
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = self
        }
    }
    
    @IBOutlet private weak var continueButton: UIButton! {
        didSet {
            continueButton.hidden = true
            continueButton.alpha = 0
        }
    }
    
    private var dependencyManager: VDependencyManager!
    
    lazy private var collectionViewDataSource: ChatInterfaceDataSource = {
        let dataSource = TutorialCollectionViewDataSource(dependencyManager: self.dependencyManager)
        dataSource.delegate = self
        
        return dataSource
    }()
    
    // MARK: - Initialization
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> TutorialViewController {
        let viewController: TutorialViewController = TutorialViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        
        return viewController
    }
    
    // MARK: - View Controller Life Cycle
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    @IBAction private func didTapContinueButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - TutotrialCollectionViewDataSourceDelegate
    
    func didFinishFetchingAllItems() {
        continueButton.hidden = false
        UIView.animateWithDuration(1.0) { [weak self] in
            self?.continueButton.alpha = 1.0
        }
    }
}
