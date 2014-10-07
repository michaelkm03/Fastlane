//
//  VSectionHandleReusableView.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSectionHandleReusableView.h"

#import "VThemeManager.h"

@interface VSectionHandleReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *handleIcon;

@end

@implementation VSectionHandleReusableView

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 37.0f);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    self.commentCountLabel.text = nil;
    self.commentCountLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
    
    self.handleIcon.image = [self.handleIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.handleIcon.tintColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
}

#pragma mark - Property Accessors

- (void)setNumberOfComments:(NSInteger)numberOfComments
{
    _numberOfComments = numberOfComments;
    
    NSString *commentText = [NSString stringWithFormat:@"%@ %@", @(numberOfComments), (numberOfComments > 1) ? NSLocalizedString(@"Comments", @"") : NSLocalizedString(@"Comment", @"")];
    
    self.commentCountLabel.text = commentText;
}

@end
