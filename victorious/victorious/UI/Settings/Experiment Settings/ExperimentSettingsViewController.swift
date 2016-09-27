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
    
    var dependencyManager: VDependencyManager?
    
    var initialExperimentIds: Set<Int>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.dataSource
        self.dataSource.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
        
        self.initialExperimentIds = self.dataSource.experimentSettings.activeExperiments
        self.dataSource.loadSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear( animated )
        
        // If any changes were made since this view was presented
        if self.dataSource.experimentSettings.activeExperiments != self.initialExperimentIds {
            NotificationCenter.defaultCenter().postNotificationName(VSessionTimerNewSessionShouldStart, object: nil)
        }
    }
}
