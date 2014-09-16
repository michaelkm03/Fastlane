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
    self.blurView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.extraColorLayer = [CALayer layer];
    self.extraColorLayer.frame = CGRectMake(0, 0, 320, 320);
    self.extraColorLayer.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5f].CGColor;
    [self.blurView.layer addSublayer:self.extraColorLayer];
    
    [self addSubview:self.blurView];
    
    [self bringSubviewToFront:self.label];
}

#pragma mark - Property Accessors

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.label.text = titleText;
}

@end
