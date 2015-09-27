//
//  VStaticVideoSequencePreviewView.h
//  victorious
//
//  Created by Patrick Lynch on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSequencePreviewView.h"

@interface VStaticVideoSequencePreviewView : VSequencePreviewView

/**
 * The image view responsible for showing the video's preview image
 */
@property (nonatomic, strong, readonly) UIImageView *previewImageView;

@end
