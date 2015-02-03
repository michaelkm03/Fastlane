//
//  VEndCardActionCell.h
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VEndCardActionCell : UICollectionViewCell

@property (nonatomic, assign) BOOL enabled;

+ (NSString *)cellIdentifier;

+ (CGSize)minimumSize;

- (void)setTitle:(NSString *)title;

- (void)setImage:(UIImage *)image;

- (void)setSuccessImage:(NSString *)successImage;

- (void)showSuccess;

- (void)setTitleAlpha:(CGFloat)alpha;

- (void)transitionInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)transitionOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion;

@end
