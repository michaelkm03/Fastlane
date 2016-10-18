//
//  ConfigurableGridStreamHeaderView.swift
//  victorious
//
//  Created by Vincent Ho on 4/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ConfigurableGridStreamHeaderView: UICollectionReusableView {
    private var header: UIView?
    
    func addHeader(_ header: UIView) {
        if self.header == header {
            return
        }
        self.header?.removeFromSuperview()
        self.header = header
        addSubview(header)
        v_addFitToParentConstraints(toSubview: header)
    }
}
