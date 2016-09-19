//
//  Tray.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol Tray: TrayDataSourceDelegate {
    weak var delegate: TrayDelegate? { get set }
}

protocol TrayDelegate: class {
    func tray(tray: Tray, selectedItemWithPreviewImage previewImage: UIImage, mediaURL: NSURL)
}
