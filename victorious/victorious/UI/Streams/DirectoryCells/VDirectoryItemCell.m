//
//  VDirectoryItemCell.m
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDirectoryItemCell.h"

// Views
#import "VExtendedView.h"

// Categories
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"

// Models
#import "VStream.h"
#import "VStream+Fetcher.h"
#import "VStreamItem+Fetcher.h"

const CGFloat kDirectoryItemBaseHeight = 217.0f;
const CGFloat kDirectoryItemStackHeight = 8.0f;
const CGFloat kDirectoryItemBaseWidth = 145.0f;

@interface VDirectoryItemCell()

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIView *streamItemContainerOrTopStackItem;
@property (nonatomic, weak) IBOutlet VExtendedView *topStack;
@property (nonatomic, weak) IBOutlet VExtendedView *middleStack;
@property (nonatomic, weak) IBOutlet VExtendedView *bottomStack;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topStackBottomConstraint;

@end

@implementation VDirectoryItemCell

#pragma mark - Sizing Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds) * .453; //from spec, 290 width on 640
    return CGSizeMake(width, [self desiredStreamOfStreamsHeightForWidth:width]);
}

+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width
{
    return [self desiredStreamOfContentHeightForWidth:width] + kDirectoryItemStackHeight;
}

+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width
{
    return  ( kDirectoryItemBaseHeight / kDirectoryItemBaseWidth ) * width;
}

#pragma mark - Property Accessors

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    
    self.countLabel.text = @"";
    if ([streamItem isKindOfClass:[VStream class]])
    {
        self.countLabel.text = [NSString stringWithFormat:@"%@ %@", ((VStream *)streamItem).count, NSLocalizedString(@"ITEMS", @"")];
    }
    
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[self.streamItem.previewImagePaths firstObject]]
                           placeholderImage:nil];
    
    BOOL isStack = ([streamItem isKindOfClass:[VStream class]] && [((VStream *)streamItem) isStreamOfStreams]);
    
    self.bottomStack.hidden = !isStack;
    self.middleStack.hidden = !isStack;
    self.topStackBottomConstraint.constant = isStack ? kDirectoryItemStackHeight : 0.0f;
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.bottomStack.hidden = YES;
    self.middleStack.hidden = YES;
}

- (void)setStackBackgroundColor:(UIColor *)stackBackgroundColor
{
    _stackBackgroundColor = stackBackgroundColor;
    for (VExtendedView *view in [self stackViews])
    {
        [view setBackgroundColor:_stackBackgroundColor];
    }
}

- (void)setStackBorderColor:(UIColor *)stackBorderColor
{
    _stackBorderColor = stackBorderColor;
    for (VExtendedView *view in [self stackViews])
    {
        [view setBorderColor:_stackBorderColor];
    }
    
}

- (NSArray *)stackViews
{
    return @[self.topStack, self.middleStack, self.bottomStack];
}

@end
