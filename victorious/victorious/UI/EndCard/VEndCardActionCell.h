//
//  VEndCardActionCell.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VEndCardActionModel.h"

@interface VEndCardActionCell : UICollectionViewCell

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, readonly) NSString *actionIdentifier;

+ (NSString *)cellIdentifier;

+ (CGSize)minimumSize;

- (void)setModel:(VEndCardActionModel *)model;

- (void)setFont:(UIFont *)font;

- (void)setTitleAlpha:(CGFloat)alpha;

- (void)showSuccess;

- (void)transitionInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)transitionOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion;

@end
