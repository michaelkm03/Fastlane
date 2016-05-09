//
//  VViewedContent+Parsable.swift
//  victorious
//
//  Created by Vincent Ho on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VViewedContent: PersistenceParsable {
    
    func populate( fromSourceModel sourceModel: ViewedContent ) {
        
        if self.author == nil {
            self.author = v_managedObjectContext.v_findOrCreateObject( [ "remoteId" : sourceModel.author.userID ] ) as VUser
        }
        self.author?.populate(fromSourceModel: sourceModel.author)
        
        if self.content == nil {
            self.content = v_managedObjectContext.v_findOrCreateObject( [ "remoteID" : sourceModel.content.id ] ) as VContent
        }
        self.content?.populate(fromSourceModel: sourceModel.content)
        self.content?.viewedContent = self
    }
}
