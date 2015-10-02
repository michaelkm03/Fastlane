//
//  VRenderablePreviewView.h
//  victorious
//
//  Created by Patrick Lynch on 9/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@protocol VRenderablePreviewView <NSObject>

/**
 Allows a context to inform the receiver of a default at which asset should rendered.
 This value is open to interpretation based on the type of class implementing the protocol,
 but in general it is used to optimize display of content.
 */
- (void)setRenderingSize:(CGSize)renderingSize;

@end
