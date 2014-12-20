//
//  VSwipeTableViewCell.m
//  SwipeCell
//
//  Created by Patrick Lynch on 12/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwipeTableViewCell.h"

@implementation VSwipeTableViewCell 

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupSwipeView];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupSwipeView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.swipeView reset];
}

- (void)setupSwipeView
{
    if ( self.swipeView != nil )
    {
        return;
    }
    
    self.swipeView = [[VSwipeView alloc] initWithFrame:self.bounds];
    self.swipeView.cellDelegate = self;
    [self.contentView addSubview:self.swipeView];
    [self.contentView sendSubviewToBack:self.swipeView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( !self.clipsToBounds && !self.hidden && self.alpha > 0 )
    {
        CGPoint subPoint = [self.swipeView.utilityButtonsContainer convertPoint:point fromView:self];
        UIView *result = [self.swipeView.utilityButtonsContainer hitTest:subPoint withEvent:event];
        if ( result != nil )
        {
            return result;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

#pragma mark - VSwipeViewCellDelegate

- (UIView *)parentCellView
{
    return self;
}

@end
