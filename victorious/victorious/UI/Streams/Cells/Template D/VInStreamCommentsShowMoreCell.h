//
//  VInStreamCommentsShowMoreCell.h
//  victorious
//
//  Created by Sharif Ahmed on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

@class VInStreamCommentsShowMoreAttributes;

@interface VInStreamCommentsShowMoreCell : VBaseCollectionViewCell

- (void)setupWithAttributes:(VInStreamCommentsShowMoreAttributes *)attributes andLinkDelegate:(id <CCHLinkTextViewDelegate>)linkDelegate;

+ (CGFloat)desiredHeightForAttributes:(VInStreamCommentsShowMoreAttributes *)attributes withMaxWidth:(CGFloat)width;

@property (nonatomic, readonly) VInStreamCommentsShowMoreAttributes *attributes;

@end
