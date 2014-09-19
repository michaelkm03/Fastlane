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


@end

@implementation VSectionHandleReusableView

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 32.0f);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    self.commentCountLabel.text = nil;
    self.commentCountLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel4Font];
}

#pragma mark - Property Accessors

- (void)setNumberOfComments:(NSInteger)numberOfComments
{
    _numberOfComments = numberOfComments;
    
    NSString *commentText = [NSString stringWithFormat:@"%@ Comment%@", @(numberOfComments), (numberOfComments > 1) ? @"s" : @""];
    
    self.commentCountLabel.text = commentText;
}

@end
