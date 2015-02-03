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

@property (nonatomic, strong) NSString *actionIdentifier;

+ (NSString *)cellIdentifier;

+ (CGSize)minimumSize;

- (void)setTitle:(NSString *)title;

- (void)setImage:(UIImage *)image;

- (void)setSuccessImage:(NSString *)successImage;

- (void)setTitleAlpha:(CGFloat)alpha;

- (void)showSuccess;

- (void)transitionInWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay;

- (void)transitionOutWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion;

@end
