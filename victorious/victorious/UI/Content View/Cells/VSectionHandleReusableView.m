//
//  VSectionHandleReusableView.m
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSectionHandleReusableView.h"

#import "VThemeManager.h"

static const CGFloat kHandleDesiredHeight = 37.0f;

@interface VSectionHandleReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *handleIcon;

@end

@implementation VSectionHandleReusableView

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kHandleDesiredHeight);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    self.commentCountLabel.text = nil;
    
    self.handleIcon.image = [self.handleIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.handleIcon.tintColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
}

#pragma mark - Property Accessors

- (void)setNumberOfComments:(NSInteger)numberOfComments
{
    _numberOfComments = numberOfComments;
    NSString *commentText = nil;
    
    if (numberOfComments == 0)
    {
        commentText = NSLocalizedString(@"LeaveAComment", @"");
    }
    else
    {
        commentText = [NSString stringWithFormat:@"%@ %@", @(numberOfComments), (numberOfComments > 1) ? NSLocalizedString(@"Comments", @"") : NSLocalizedString(@"Comment", @"")];
    }

    self.commentCountLabel.attributedText = [[NSAttributedString alloc] initWithString:commentText
                                                                            attributes:@{
                                                                                         NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font],
                                                                                         NSForegroundColorAttributeName : [UIColor colorWithRed:35/255.0f green:35/255.0f blue:35/255.0f alpha:1.0f]
                                                                                         }];
}

@end
