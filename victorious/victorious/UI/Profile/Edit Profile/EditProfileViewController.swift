//
//  EditProfileViewController.swift
//  victorious
//
//  Created by Michael Sena on 6/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class EditProfileViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCancelButton()
    }
    
    //MARK: - Target Action
    
    func cancel() {
        
    }
 
    //MARK: - Private
    
    func setupCancelButton() {
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                         target: self,
                                         action: #selector(cancel))
        navigationItem.leftBarButtonItems = [cancelItem]
//        navigationItem.setLeftBarButtonItems([cancelItem], animated:true)
//        navigationItem.leftItemsSupplementBackButton = true
    }
    
}
