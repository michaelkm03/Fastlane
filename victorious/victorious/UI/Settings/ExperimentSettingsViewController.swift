//
//  ExperimentSettingsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// This equality operator comapres two arrays of strings that are expected to contain integer text
/// such as "1" or "2".  It converts the strings to integers, sorts, then compares with the `Array`
/// type's default equality operator.
private func ==( lhs: [String], rhs: [String] ) -> Bool {
    if rhs.count == lhs.count {
        return false
    }
    return lhs.map({ $0.toInt()! }).sorted{ $0 < $1 } == rhs.map({ $0.toInt()! }).sorted{ $0 < $1 }
}

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
        
        self.dataSource.loadSettings() {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear( animated )
        
        self.dataSource.saveSettings()
    }
}

protocol ExperimentSettingsDataSourceDelegate {
    var tableView: UITableView! { get }
}

class ExperimentSettingsDataSource: NSObject {
    
    var delegate:ExperimentSettingsDataSourceDelegate?
    
    enum State: Int {
        case Loading, Content, NoContent, Error
        
        /// Returns a message to display to the user for this state
        /// Non-localized, as this is for testing purposes only
        var message: String {
            switch self {
            case .Error:
                return "An error occured while loading the list of available experiments."
            case .NoContent:
                return "There are no experiments running right now."
            case .Loading:
                return "  Loading experiments..."
            default:
                return ""
            }
        }
    }
    
    struct Section {
        let title: String
        let experiments: [Experiment]
    }
    private var sections = [Section]()
    
    private var userEnabledExperimentIds = [String]()
    private var defaultEnabledExperimentIds = [String]()
    private var state: State = .Loading
    
    private func saveSettings() {
        // If the user changed any settings from the default (the backend settings)...
        if self.defaultEnabledExperimentIds != self.userEnabledExperimentIds {
            
            // ...we should update the `experimentIDs` in `VObjectManager` to add the header
            // which actually changes experiment membership
            VObjectManager.sharedManager().experimentIDs = self.userEnabledExperimentIds
        }
        else {
            // Otherwise, set the `experimentIDs` back to nil so that the header is not added
            // and the backend's experiment membership settings are applied as normal
            VObjectManager.sharedManager().experimentIDs = nil
        }
    }
    
    func loadSettings( completion:(()->())? ) {
        self.state = .Loading
        
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
                
                if let experiments = results as? [Experiment] {
                    let layers = Set<String>( map(experiments, { $0.layerName }) )
                    for layer in layers {
                        let experiments = filter(experiments, { $0.layerName == layer })
                        self.sections.append( Section(title: layer, experiments: experiments) )
                    }
                }
                completion?()
                
                self.state = self.sections.count > 0 ? .Content : .NoContent
            },
            failure: { (operation, error) -> Void in
                self.sections = []
                self.state = .Error
                completion?()
            }
        )
    }
}

extension ExperimentSettingsDataSource: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = VSettingsSwitchCell.suggestedReuseIdentifier()
        if self.state == .Content, let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
        
            let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
            let enabled = contains( self.userEnabledExperimentIds, experiment.id )
            cell.setTitle( experiment.name, value: enabled )
            cell.delegate = self
            return cell
        }
        
        let noContentIdentifier = SettingsEmptyCell.defaultSwiftReuseIdentifier
        if let cell = tableView.dequeueReusableCellWithIdentifier( noContentIdentifier, forIndexPath: indexPath ) as? SettingsEmptyCell {
            cell.message = self.state.message
            return cell
        }
            
        fatalError( "Could not load cell" )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max( self.sections[ section ].experiments.count, 1 )
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[ section ].title
    }
}

extension ExperimentSettingsDataSource: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.delegate?.tableView.indexPathForCell( cell ) {
            
            let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
            if cell.value {
                self.userEnabledExperimentIds.append( experiment.id )
            }
            else {
                self.userEnabledExperimentIds = self.userEnabledExperimentIds.filter { $0 != experiment.id }
            }
        }
    }
}
