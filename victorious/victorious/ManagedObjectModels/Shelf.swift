//
//  Shelf.swift
//  
//
//  Created by Sharif Ahmed on 8/19/15.
//
//

import Foundation
import CoreData
import VictoriousIOSSDK

class Shelf: VStream {

    @NSManaged var title: String
    @NSManaged var streamUrl: String
    
    func populate(fromSourceShelf sourceShelf: StreamItemType) {
        guard let shelf = sourceShelf as? VictoriousIOSSDK.Shelf else { return }
        
        super.populate(fromSourceModel: shelf)
        
        title = shelf.title ?? ""
        streamUrl = shelf.apiPath ?? ""
    }
}
