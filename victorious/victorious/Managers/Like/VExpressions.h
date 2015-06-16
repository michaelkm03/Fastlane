//
//  VExpressions.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

@protocol VExpressionButton <NSObject>

- (void)setActive:(BOOL)active;

- (void)setCount:(NSUInteger)count;

@end

@protocol VExpressionButtonProvider <NSObject>

@property (nonatomic, strong) UIButton<VExpressionButton> *likeButton;

@end