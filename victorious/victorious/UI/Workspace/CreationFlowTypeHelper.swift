//
//  CreationFlowTypeHelper.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc(VCreationFlowTypeHelper)
class CreationFlowTypeHelper: NSObject {
    
    private static let creationFlowTypes: [String : VCreationFlowType] = [
        "Create Image": .image,
        "Create Video": .video,
        "Create Poll": .poll,
        "Create Text": .text,
        "Create GIF": .GIF,
        "Create from Library": .library,
        "Create from Native Camera": .nativeCamera]
    
    static func creationFlowTypeForIdentifier(_ identifier: String) -> VCreationFlowType {
        return creationFlowTypes[identifier] ?? .unknown
    }
}
