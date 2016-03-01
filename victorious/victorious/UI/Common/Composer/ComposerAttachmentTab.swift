//
//  ComposerControllerAttachmentTab.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum ComposerControllerAttachmentTab {
    
    private struct Icon {
        
        //TODO: Replace with real icon names once assets are imported
        static let camera = UIImage(named: "camera")!
        static let library = UIImage(named: "library")!
        static let gif = UIImage(named: "gif")!
    }
    
    case Camera, Library, Gif
    
    func associatedIcon() -> UIImage {
        switch self {
            case .Camera:
                return Icon.camera
            case .Library:
                return Icon.library
            case .Gif:
                return Icon.gif
        }
    }
}
