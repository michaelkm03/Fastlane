//
//  ComposerAttachmentTab.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum ComposerAttachmentTab {
    
    private struct Icon {
        
        static let camera = UIImage(named: "action_sheet_block")!
        static let library: UIImage! = nil
        static let gif: UIImage! = nil
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
