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
    
    private var allExperiments = [Experiment]()
    private var enabledExperimentIds = [String]()
    
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
        VObjectManager.sharedManager().experimentIDs = self.enabledExperimentIds
    }
    
    private func loadSettings( completion: ()->() ) {
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, results) -> Void in
                if let result = result as? [String: AnyObject] {
                    self.enabledExperimentIds = {
                        if let manuallyConfiguredExperimentIds = VObjectManager.sharedManager().experimentIDs as? [String] {
                            return manuallyConfiguredExperimentIds
                        }
                        else if let serverConfiguredExperimentIds = result[ "experiment_ids" ] as? [String] {
                            return serverConfiguredExperimentIds
                        }
                        return []
                    }()
                }
                
                if let allExperiments = results as? [Experiment] {
                    self.allExperiments = allExperiments
                }
                completion()
            },
            failure: { (operation, error) -> Void in
                self.allExperiments = []
                completion()
            }
        )
    }
}

extension ExperimentSettingsViewController: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.tableView.indexPathForCell( cell ) {
            let experiment = self.allExperiments[ indexPath.row ]
            if cell.value {
                self.enabledExperimentIds.append( experiment.id )
            }
            else {
                self.enabledExperimentIds = self.enabledExperimentIds.filter { $0 != experiment.id }
            }
        }
    }
}

extension ExperimentSettingsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "VSettingsSwitchCell"
        if let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
            
            let experiment = self.allExperiments[ indexPath.row ]
            let enabled = contains( self.enabledExperimentIds, experiment.id )
            cell.setTitle( experiment.name, value: enabled )
            cell.delegate = self
            return cell
        }
        fatalError( "Could not load cell" )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allExperiments.count
    }
}