//
//  VSeeMoreDirectoryItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 2/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSeeMoreDirectoryItemCell.h"
#import "VExtendedView.h"
#import "VThemeManager.h"

NSString * const VSeeMoreDirectoryItemCellNameStream = @"VStreamSeeMoreDirectoryItemCell";

@interface VSeeMoreDirectoryItemCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstriant;
@property (nonatomic, weak) IBOutlet VExtendedView *extendedView;

@end

@implementation VSeeMoreDirectoryItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.seeMoreLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

- (void)updateBottomConstraintToConstant:(CGFloat)constant
{
    if ( self.bottomConstriant.constant != constant )
    {
        self.bottomConstriant.constant = constant;
        [self layoutIfNeeded];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [self.extendedView setBackgroundColor:backgroundColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self.extendedView setBorderColor:_borderColor];
}

@end
