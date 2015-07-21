//
//  ExperimentSettingsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc class Experiment: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var enabled: NSNumber
    @NSManaged var id: NSNumber
}

extension Experiment {
    
    static var entityMapping: RKEntityMapping {
        let propertyMap = [
            "name"  : "name",
            "id"    : "id" ]
        
        var store = RKObjectManager.sharedManager().managedObjectStore
        var mapping = RKEntityMapping(forEntityForName: self.v_defaultEntityName, inManagedObjectStore: store )
        mapping.addAttributeMappingsFromDictionary( propertyMap )
        mapping.identificationAttributes = [ "id" ]
        return mapping
    }
    
    static var descriptors: NSArray {
        return [
            RKResponseDescriptor(
                mapping: self.entityMapping,
                method: RKRequestMethod.GET,
                pathPattern: "/api/device/experiments",
                keyPath: "payload",
                statusCodes: RKStatusCodeIndexSetForClass(UInt(RKStatusCodeClassSuccessful))
            )
        ]
    }
}

extension VObjectManager {
    
    func getDeviceExperiments( #success: VSuccessBlock, failure: VFailBlock ) -> RKManagedObjectRequestOperation? {
        
        let params = [ "" : "" ]
        return self.GET( "/api/device/experiments", object: nil, parameters: params, successBlock: success, failBlock: failure )
    }
    
    func setDeviceExperiments( #success: VSuccessBlock, failure: VFailBlock ) -> RKManagedObjectRequestOperation? {
        
        let params = [ "" : "" ]
        return self.POST( "/api/device/experiments", object: nil, parameters: params, successBlock: success, failBlock: failure )
    }
}

extension ExperimentSettingsViewController: UITableViewDataSource {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let experiment = self.experiments[ indexPath.row ]
        let identifier = "VSettingsSwitchCell"
        if let cell = tableView.dequeueReusableCellWithIdentifier( identifier, forIndexPath: indexPath ) as? VSettingsSwitchCell {
            cell.setTitle( experiment.name, value: experiment.enabled.boolValue )
            cell.delegate = self
        }
        fatalError( "Could not load cell" )
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experiments.count
    }
}

class ExperimentSettingsViewController: UITableViewController {
    
    let experiments = [Experiment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSettings() {
            self.tableView.reloadData()
        }
    }
    
    func loadSettings( completion: ()->() ) {
        VObjectManager.sharedManager().getDeviceExperiments(
            success: { (operation, result, results) -> Void in
                println( result )
            },
            failure: { (operation, error) -> Void in
                println( error )
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