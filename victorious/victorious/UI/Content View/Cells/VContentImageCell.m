//
//  VContentImageCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentImageCell.h"

@interface VContentImageCell ()

@property (nonatomic, weak) IBOutlet UIView *backgroundContainer;
@property (nonatomic, assign) BOOL updatedImageBounds;

@end

@implementation VContentImageCell

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.shrinkingContentView = self.contentImageView;
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - UIView

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if ( !self.updatedImageBounds )
    {
        /*
         Updating imageView bounds after first time bounds is set
         Assumes cell will never be re-updated to a new "full" size but allows normal content
         resizing to work its magic
         */
        self.updatedImageBounds = YES;
        self.contentImageView.frame = bounds;
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)vBackgroundContainerView
{
    return self.backgroundContainer;
}

@end
