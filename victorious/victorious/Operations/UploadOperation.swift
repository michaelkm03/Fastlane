//
//  UploadOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol UploadOperation {
    typealias ParameterType

    var uploadManager: VUploadManager { get }
    var previewImage: UIImage { get }
    var formFields: [NSObject : AnyObject] { get }
    
    init?(parameters: ParameterType, previewImage: UIImage, uploadManager: VUploadManager)
    
    func upload(uploadManager: VUploadManager)
}
