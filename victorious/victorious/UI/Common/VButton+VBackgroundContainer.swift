//
//  VButton+VBackgroundContainer.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VButton: VBackgroundContainer {
    public func backgroundContainerView() -> UIView {
        return self
    }
}
