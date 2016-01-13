//
//  VTextToolController.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VTextToolController {
    
    /// Used to unwrap the weak property `textPostViewController`
    private var textPostVC: VEditableTextPostViewController {
        return textPostViewController!
    }
    
    var currentText: String {
        return textPostVC.textOutput
    }
    
    var currentColorSelection: UIColor {
        let colorPicker = textColorTool?.toolPicker
        if let selectedTool = colorPicker?.selectedTool as? VColorType {
            return selectedTool.color
        } else {
            return textPostVC.dependencyManager.colorForKey(VDependencyManagerAccentColorKey)
        }
    }
    
    var textPostPreviewImage: UIImage {
        let viewToDraw = textPostVC.view
        
        UIGraphicsBeginImageContextWithOptions(viewToDraw.bounds.size, true, 0.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func publishTextPost(renderedAssetURL: NSURL, completion: (finished: Bool, renderedMediaURL: NSURL?, previewImage: UIImage?, error: NSError?) -> Void) {
        
        let parameters = TextPostParameters(content: currentText, backgroundImageURL: renderedAssetURL, backgroundColor: currentColorSelection)
        let operation = CreateTextPostOperation(parameters: parameters)
        
        operation?.queue() { error in
            if error == nil {
                completion(finished: true, renderedMediaURL: nil, previewImage: nil, error: nil)
            } else {
                completion(finished: false, renderedMediaURL: nil, previewImage: nil, error: nil)
            }
        }
    }
}
