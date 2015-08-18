//
//  VTextPostTextView.h
//  victorious
//
//  Created by Patrick Lynch on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCHLinkTextView.h"

/**
 A custom UITextView subclass that provides drawing routines necessary
 to render background frames behind its text.
 */
@interface VTextPostTextView : CCHLinkTextView

/**
 The drames to be drawing.  This setter will automatically trigger the view
 into redrawing its background upon updating.
 */
@property (nonatomic, strong) NSArray *backgroundFrames;

/**
 The color used to draw the background frames.
 */
@property (nonatomic, strong) UIColor *backgroundFrameColor;

/**
 Convenience method that allows calling to quickly request the rectangle
 for a range of characters from its current text value.
 */
- (CGRect)boundingRectForCharacterRange:(NSRange)range;

@end
