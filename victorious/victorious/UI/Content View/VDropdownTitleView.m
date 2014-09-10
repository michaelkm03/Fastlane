//
//  VDropdownTitleView.m
//  victorious
//
//  Created by Michael Sena on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDropdownTitleView.h"

@interface VDropdownTitleView ()

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) CALayer *extraColorLayer;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation VDropdownTitleView

- (void)awakeFromNib
{
    self.blurView = [[UIToolbar alloc] initWithFrame:self.bounds];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.extraColorLayer = [CALayer layer];
    self.extraColorLayer.frame = CGRectMake(0, 0, self.blurView.frame.size.width, self.blurView.frame.size.height);
    self.extraColorLayer.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f].CGColor;
    [self.blurView.layer addSublayer:self.extraColorLayer];
    
    [self addSubview:self.blurView];
    
    [self bringSubviewToFront:self.label];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    [self layoutSubviews];
    
    self.extraColorLayer.frame = self.blurView.bounds;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    
}

@end
