//
//  UniqueIdentificationMessage.swift
//  victorious
//
//  Created by Sebastian Nystorm on 6/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Used to identify each of the outgoing messages over the WebSocket. 
class UniqueIdentificationMessage: DictionaryConvertible {

    private var sequenceCounter: Int = 0

    /// The uniqueue ID of the device.
    var deviceID: String = ""

    /// Increments the counter by one.
    func incrementSequenceCounter() {
        sequenceCounter += 1
    }

    /// Resets the counter to 0.
    func resetSequenceCounter() {
        sequenceCounter = 0
    }

    // MARK: DictionaryConvertible

    var rootKey: String {
        return "vuid"
    }

    var rootTypeKey: String? {
        return nil
    }

    var rootTypeValue: String? {
        return nil
    }

    func toDictionary() -> [String: AnyObject] {
        var dictionary = [String: AnyObject]()
        dictionary["source"] = deviceID as AnyObject?
        dictionary["sequence"] = sequenceCounter as AnyObject?
        return dictionary
    }
}
