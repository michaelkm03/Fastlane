//
//  VStaticVideoSequencePreviewView.m
//  victorious
//
//  Created by Patrick Lynch on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import "VStaticVideoSequencePreviewView.h"
#import "UIView+AutoLayout.h"

@interface VStaticVideoSequencePreviewView()

@property (nonatomic, strong) UIButton *largePlayButton;

@end

@implementation VStaticVideoSequencePreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
        [self addSubview:_previewImageView];
        [self v_addFitToParentConstraintsToSubview:_previewImageView];
        
        UIImage *playIcon = [UIImage imageNamed:@"play-btn-icon"];
        _largePlayButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_largePlayButton setImage:playIcon forState:UIControlStateNormal];
        _largePlayButton.backgroundColor = [UIColor clearColor];
        [self addSubview:_largePlayButton];
        [self v_addCenterToParentContraintsToSubview:_largePlayButton];
    }
    return self;
}

@end
