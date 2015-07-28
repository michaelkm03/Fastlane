//
//  ExperimentSettingsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Simple table view controller that loads all available experiments from the server
/// and displays each one in a cell with a switch to allow the user to opt in or out
/// of the experiment.
class ExperimentSettingsViewController: UITableViewController, ExperimentSettingsDataSourceDelegate {
    
    let dataSource = ExperimentSettingsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.dataSource
        self.dataSource.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
        self.dataSource.loadSettings()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear( animated )
        
        self.dataSource.saveSettings()
    }
}
