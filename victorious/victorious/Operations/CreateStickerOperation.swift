//
//  CreateStickerOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CreateStickerOperation: SyncOperation<Void> {
    let request: StickerCreateRequest
    
    init?(apiPath: APIPath, content: Content) {
        guard
            let params = CreateStickerOperation.formFields(for: content),
            let request = StickerCreateRequest(apiPath: apiPath, formParams: params)
        else {
            return nil
        }
        self.request = request
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        RequestOperation(request: request).queue()
        return .success()
    }
    
    private static func formFields(for content: Content) -> [NSObject : AnyObject]? {
        guard
            let asset = content.assets.first,
            let size = asset.size
        else {
            return nil
        }
        
        return [
            "is_vip": content.isVIPOnly ? "true" : "false",
            "width": size.width,
            "height": size.height
        ]
    }
}
