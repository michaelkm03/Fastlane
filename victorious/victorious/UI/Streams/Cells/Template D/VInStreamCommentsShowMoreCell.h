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

/**
    A cell representing the "show more" action for in stream comments.
 */
@interface VInStreamCommentsShowMoreCell : VBaseCollectionViewCell

/**
    Styles the cell and provides a delegate for the link text view displaying the "show more" text.
 
    @param attributes The attributes that should be used to style the cell.
    @param linkDelegate A delegate for the link text view displaying the "show more" text.
 */
- (void)setupWithAttributes:(VInStreamCommentsShowMoreAttributes *)attributes andLinkDelegate:(id <CCHLinkTextViewDelegate>)linkDelegate;

/**
    The ideal height for this cell.
 
    @param attributes The display attributes for this cell.
    @param width The maximum width of this cell.
 
    @return The ideal height for this cell.
 */
+ (CGFloat)desiredHeightForAttributes:(VInStreamCommentsShowMoreAttributes *)attributes withMaxWidth:(CGFloat)width;

/**
    The attributes currently styling this cell.
 */
@property (nonatomic, readonly) VInStreamCommentsShowMoreAttributes *attributes;

@end
