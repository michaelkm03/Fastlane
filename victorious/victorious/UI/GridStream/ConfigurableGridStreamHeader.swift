//
//  ConfigurableGridStreamHeader.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers of this protocol can be added into the ConfigurableHeaderContentStreamViewController as a header.
protocol ConfigurableGridStreamHeader {
    associatedtype ContentType

    func decorateHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: ContentType?, hasError: Bool)

    func sizeForHeader(dependencyManager: VDependencyManager, maxHeight: CGFloat, content: ContentType?, hasError: Bool) -> CGSize

    func headerDidDisappear()

    func headerWillAppear()
    
    func gridStreamDidUpdateDataSource(with items: [ContentModel])
    
    func gridStreamShouldRefresh()
}

extension ConfigurableGridStreamHeader {
    func headerDidDisappear() {
        
    }
    
    func headerWillAppear() {
        
    }
    
    func gridStreamDidUpdateDataSource(with items: [ContentModel]) {
        
    }
    
    func gridStreamShouldRefresh() {
        
    }
}
