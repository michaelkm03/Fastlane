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

    func headerWillDisappear()

    func headerDidAppear()
    
    func gridStreamDidUpdateDataSource(with items: [Content])
    
    func gridStreamShouldRefresh()
}

extension ConfigurableGridStreamHeader {
    func headerWillDisappear() {
        
    }
    
    func headerDidAppear() {
        
    }
    
    func gridStreamDidUpdateDataSource(with items: [Content]) {
        
    }
    
    func gridStreamShouldRefresh() {
        
    }
}
