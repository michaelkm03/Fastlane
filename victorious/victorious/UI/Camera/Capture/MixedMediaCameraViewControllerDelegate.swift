//
//  MixedMediaCameraViewControllerDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol MixedMediaCameraViewControllerDelegate: class {
    
    func mixedMediaCameraViewController(mixedMediaCameraViewController: MixedMediaCameraViewController, capturedImageWithMediaURL mediaURL: NSURL, previewImage: UIImage)
}
