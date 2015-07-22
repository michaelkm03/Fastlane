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
class ExperimentSettingsViewController: UITableViewController {
    
    private var allAvailableExperiments = [Experiment]()
    
    private var defaultEnabledExperimentIds = [String]()
    private var userEnabledExperimentIds = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
        self.loadSettings() {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear( animated )
        
        self.saveSettings()
    }
    
    private func saveSettings() {
        VObjectManager.sharedManager().experimentIDs = self.userEnabledExperimentIds
    }
    
    private func loadSettings( completion: ()->() ) {
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, results) -> Void in
                if let result = result as? [String: AnyObject] {
                    
                    // Get the enabled experiments as determined by the server without overriding
                    if let serverConfiguredExperimentIds = result[ "experiment_ids" ] as? [String] {
                        self.defaultEnabledExperimentIds = serverConfiguredExperimentIds
                    }
                    
                    // Get any overrides previosuly selected from this settings view
                    if let manuallyConfiguredExperimentIds = VObjectManager.sharedManager().experimentIDs as? [String] {
                        self.userEnabledExperimentIds = manuallyConfiguredExperimentIds
                    }
                    // But if there are none, use the defaults provided by the server
                    else {
                        self.userEnabledExperimentIds = self.defaultEnabledExperimentIds
                    }
                }
                
                if let allAvailableExperiments = results as? [Experiment] {
                    self.allAvailableExperiments = allAvailableExperiments
                }
                completion()
            },
            failure: { (operation, error) -> Void in
                self.allAvailableExperiments = []
                completion()
            }
        )
    }
}

extension ExperimentSettingsViewController: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.tableView.indexPathForCell( cell ) {
            let experiment = self.allAvailableExperiments[ indexPath.row ]
            if cell.value {
                self.userEnabledExperimentIds.append( experiment.id )
            }
            else {
                self.userEnabledExperimentIds = self.userEnabledExperimentIds.filter { $0 != experiment.id }
            }
        }
    }
}

extension ExperimentSettingsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "VSettingsSwitchCell"
        if let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
            
            let experiment = self.allAvailableExperiments[ indexPath.row ]
            let enabled = contains( self.userEnabledExperimentIds, experiment.id )
            cell.setTitle( experiment.name, value: enabled )
            cell.delegate = self
            return cell
        }
        fatalError( "Could not load cell" )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAvailableExperiments.count
    }
}