//
//  VWorkspaceToolButton.m
//  victorious
//
//  Created by Michael Sena on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceToolButton.h"

static const CGFloat kHighlightedAlpha = 0.7f;
static const CGFloat kHighlightedScale = 0.8f;

@interface VWorkspaceToolButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation VWorkspaceToolButton

- (void)setTool:(id<VWorkspaceTool>)tool
{
    _tool = tool;
    
    [self setImage:[tool icon] forState:UIControlStateNormal];
    [self setImage:[tool selectedIcon] forState:UIControlStateSelected];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.circleLayer == nil)
    {
        self.circleLayer = [CAShapeLayer layer];
        [self.layer insertSublayer:self.circleLayer atIndex:0];
        self.circleLayer.fillColor = self.selected ? self.selectedColor.CGColor : self.unselectedColor.CGColor;
    }
    
    self.circleLayer.bounds = self.bounds;
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    self.circleLayer.path = circlePath.CGPath;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.circleLayer.fillColor = selected ? self.selectedColor.CGColor : self.unselectedColor.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.alpha = highlighted ? kHighlightedAlpha : 1.0f;
    self.circleLayer.affineTransform = highlighted ? CGAffineTransformMakeScale(kHighlightedScale, kHighlightedScale) : CGAffineTransformIdentity;
}

@end
