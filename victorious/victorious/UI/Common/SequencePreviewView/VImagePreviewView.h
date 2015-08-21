//
//  VImagePreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

//Describes a preview view that handles an image.
@protocol VImagePreviewView <NSObject>

/**
 Hides or shows the background that holds the image view. Defaults to hidden.
 
 @parameter visible If YES, the background container is made visible without animation.
 */
- (void)makeBackgroundContainerViewVisible:(BOOL)visible;

/**
 The image view that displays the sequence preview image.
 */
- (UIImageView *)previewImageView;

@end