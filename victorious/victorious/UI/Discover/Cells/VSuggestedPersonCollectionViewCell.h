//
//  VSuggestedPersonCollectionViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSuggestedPersonCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isFollowed;

+ (UIImage *)followedImage;
+ (UIImage *)followImage;

- (IBAction)onFollow:(id)sender;

@end
