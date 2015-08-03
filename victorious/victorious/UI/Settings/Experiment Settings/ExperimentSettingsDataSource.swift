//
//  ExperimentSettingsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Designed to provided an `ExperimentSettingsDataSource` instance with a reference to
/// the table view it's feeding so that it can reload it or get access to individual cells
/// that need updating based on changes in the data model
protocol ExperimentSettingsDataSourceDelegate {
    var tableView: UITableView! { get }
    var dependencyManager: VDependencyManager? { get }
}

class ExperimentSettingsDataSource: NSObject {
    
    var delegate:ExperimentSettingsDataSourceDelegate?
    
    let experimentSettings = ExperimentSettings()
    
    private enum State: Int {
        case Loading, Content, NoContent, Error
        
        /// Returns a message to display to the user for this state.
        /// Non-localized, as this is for testing purposes only.
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
    private var state: State = .Loading
    
    func saveSettings() {
        self.experimentSettings.activeExperiments = Set<Int>( self.sections.flatMap { $0.experiments.filter { $0.isEnabled.boolValue }.map { $0.id.integerValue } } )
    }
    
    func loadSettings() {
        self.state = .Loading
        
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, resultObjects) -> Void in
                self.sections = []
                
                let remoteExperimentIds = Set<Int>( result?[ "experiment_ids" ] as? [Int] ?? [Int]() )
                
                // Set experiment enabled if ID is present in self.experimentIDs
                let experiments = resultObjects as? [Experiment] ?? [Experiment]()
                
                for experiment in experiments.filter({ remoteExperimentIds.contains($0.id.integerValue) }) {
                    experiment.isEnabled = true
                }
                
                let layers = Set<String>( map( experiments, { $0.layerName }) )
                for layer in layers {
                    let experimentsInLayer = filter( experiments, { $0.layerName == layer })
                    self.sections.append( Section(title: layer, experiments: experimentsInLayer) )
                }
                
                self.state = self.sections.count > 0 ? .Content : .NoContent
                self.delegate?.tableView.reloadData()
            },
            failure: { (operation, error) -> Void in
                self.sections = []
                self.state = .Error
            }
        )
    }
}

extension ExperimentSettingsDataSource: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let noContentIdentifier = SettingsEmptyCell.defaultSwiftReuseIdentifier
        if self.state != .Content,
            let cell = tableView.dequeueReusableCellWithIdentifier( noContentIdentifier, forIndexPath: indexPath ) as? SettingsEmptyCell {
                cell.message = self.state.message
                return cell
        }
        
        let buttonCellIdentifier = SettingsButtonCell.defaultSwiftReuseIdentifier
        if self.state == .Content && indexPath.section == tableView.lastSection(),
            let cell = tableView.dequeueReusableCellWithIdentifier( buttonCellIdentifier, forIndexPath: indexPath ) as? SettingsButtonCell {
                if let button = cell.button as? VButton,
                    let color = self.delegate?.dependencyManager?.colorForKey( VDependencyManagerLinkColorKey ),
                    let font = self.delegate?.dependencyManager?.fontForKey( VDependencyManagerHeaderFontKey ) {
                        button.primaryColor = color
                        button.titleLabel?.font = font
                        button.style = .Primary
                }
                cell.delegate = self
                return cell
        }
        
        let identifier = VSettingsSwitchCell.suggestedReuseIdentifier()
        if self.state == .Content,
            let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
                let experiment = self.sections[ indexPath.section ].experiments[ indexPath.row ]
                cell.setTitle( experiment.name, value: experiment.isEnabled.boolValue )
                cell.delegate = self
                return cell
        }
        
        fatalError( "Could not load cell" )
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .Content where section != tableView.lastSection():
            return self.sections[ section ].experiments.count
        default:
            return 1 // No content/loading cell
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch state {
        case .Content:
            return self.sections.count + 1 // Reset button
        default:
            return 1 // No content/loading cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch state {
        case .Content where section != tableView.lastSection():
            return self.sections[ section ].title
        default:
            return ""
        }
    }
}

private extension UITableView {
    func lastSection() -> Int {
        return max( 0, self.numberOfSections() - 1)
    }
}

extension ExperimentSettingsDataSource: VSettingsSwitchCellDelegate {
    
    func settingsDidUpdateFromCell( cell: VSettingsSwitchCell ) {
        if let indexPath = self.delegate?.tableView.indexPathForCell( cell ) {
            
            let section = self.sections[ indexPath.section ]
            let selectedExperiment = section.experiments[ indexPath.row ]
            for experiment in section.experiments {
                experiment.isEnabled = selectedExperiment == experiment ? cell.value : false
            }
            
            // Update values only on visible cells that need updating
            for i in 0..<section.experiments.count {
                let otherCellIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
                if otherCellIndexPath != indexPath,
                    let cell = self.delegate?.tableView.cellForRowAtIndexPath( otherCellIndexPath ) as? VSettingsSwitchCell {
                        cell.setValue(false, animated: true)
                }
            }
        }
    }
}

extension ExperimentSettingsDataSource: SettingsButtonCellDelegate {
    
    func buttonPressed( button: UIButton ) {
        self.experimentSettings.reset()
    }
}




