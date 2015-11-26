//
//  PersistentStoreType.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that can be used to interact with a persistent store stack that provides implementations
/// for `PersistentStoreContext(Basic)`, such as CoreData.
/// Application code will program to this interface, allowing the concrete implementation to change.
@objc protocol PersistentStoreTypeBasic {
    
    /// Designed for main-thread reads, which blocks the thread to ensure a result can be generated
    /// through the `PersistentStoreContextBasic` instance provided when the `closure` parameter is called.
    /// The closure is called synchronously using the main context of the persistent store.
    func syncBasic( closure: ((PersistentStoreContextBasic)->()) )
    
    /// Executes a closure asynchronously using the background context of the persistent store.
    /// This method should be used for any asynchronous, concurrent data operations, such as
    /// parsing a network response into the peristent store.
    func asyncFromBackgroundBasic( closure: ((PersistentStoreContextBasic)->()) )
}

/// Adds Swift-only generics.
protocol PersistentStoreType: PersistentStoreTypeBasic {
    
    /// Executes a closure synchronously using the main context of the persistent store.
    /// Keep in mind, the generic type can be Void if no result is desired.
    func sync<T>( closure: ((PersistentStoreContext)->(T)) ) -> T
    

    /// Executes a closure asynchronously using the main context of the persistent store.
    func async( closure: ((PersistentStoreContext)->()) )
    
    /// Executes a closure synchronously using the background context of the persistent store.
    /// This method should be used for any concurrent data operations, such as
    /// parsing a network response into the peristent store.
    /// Keep in mind, the generic type can be Void if no result is desired.
    func syncFromBackground<T>( closure: ((PersistentStoreContext)->(T)) ) -> T
    
    /// Executes a closure asynchronously using the background context of the persistent store.
    /// This method should be used for any asynchronous, concurrent data operations, such as
    /// parsing a network response into the peristent store.
    func asyncFromBackground( closure: ((PersistentStoreContext)->()) )
}