//
//  ExperimentSettingsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ExperimentSettingsViewController: UITableViewController {
    
    var experiments = [Experiment]()
    
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
        VObjectManager.sharedManager().setDeviceExperiments(
            success: { (operation, result, results) in
            },
            failure: { (operation, error) in
            }
        )
    }
    
    private func loadSettings( completion: ()->() ) {
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, results) -> Void in
                if let experiments = results as? [Experiment] {
                    self.experiments = experiments
                }
                completion()
            },
            failure: { (operation, error) -> Void in
                self.experiments = []	
                completion()
            }
        )
    }
}

extension ExperimentSettingsViewController: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.tableView.indexPathForCell( cell ) {
            let experiment = self.experiments[ indexPath.row ]
            experiment.enabled = cell.value
        }
    }
}

extension ExperimentSettingsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let experiment = self.experiments[ indexPath.row ]
        let identifier = "VSettingsSwitchCell"
        if let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
            cell.setTitle( experiment.name, value: experiment.enabled.boolValue )
            cell.delegate = self
            return cell
        }
        fatalError( "Could not load cell" )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experiments.count
    }
}