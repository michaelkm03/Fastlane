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

- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical;
- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isVertical progress:(CGFloat)progress;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
