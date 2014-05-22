//
//  VResultView.h
//  victorious
//
//  Created by Will Long on 3/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VResultView : UIView

@property (nonatomic) BOOL isVertical;
@property (strong, nonatomic) UIColor* color;

- (instancetype)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical;
- (instancetype)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical progress:(CGFloat)progress;

//Progress: float value between 0 and 1;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
