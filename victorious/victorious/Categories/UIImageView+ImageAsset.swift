//
//  UIImageView+ImageAsset.swift
//  victorious
//
//  Created by Tian Lan on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImageAsset(imageAsset: ImageAssetModel, completion: (UIImage?, NSError?) -> Void) {
        switch imageAsset.imageSource {
            case .remote(let url):
                sd_setImageWithURL(
                    url,
                    placeholderImage: image,
                    options: .AvoidAutoSetImage
                ) { image, error, _, _ in
                    completion(image, error)
                }

            case .local(let image):
                self.image = image
                completion(image, nil)
        }
    }
}
