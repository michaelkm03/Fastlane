//
//  ExperimentSettings.swift
//  victorious
//
//  Created by Patrick Lynch on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class ExperimentSettings: NSObject {
    
    static let experimentsKey = "com.getvictorious.experiments.active_experiments"
    
    var activeExperiments = Set<Int>() { didSet { self.save() } }
    
    override init() {
        super.init()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.activeExperiments = defaults.objectForKey( ExperimentSettings.experimentsKey ) as? Set<Int> ?? Set<Int>()
    }
    
    private func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject( self.activeExperiments, forKey: ExperimentSettings.experimentsKey )
    }
    
    func reset() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey( ExperimentSettings.experimentsKey )
    }
    
    var commaSeparatedList: String {
        return ",".join( Array(self.activeExperiments).map { String($0) ?? "" }.filter { $0 != "" } )
    }
}