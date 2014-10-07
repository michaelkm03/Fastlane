//
//  VSuggestedPersonCollectionViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUser.h"

@protocol VSuggestedPersonCollectionViewCellDelegate

@required
- (void)unfollowPerson:(VUser *)user;
- (void)followPerson:(VUser *)user;

@end

@interface VSuggestedPersonCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) VUser *user;

+ (UIImage *)followedImage;
+ (UIImage *)followImage;

@property (nonatomic, weak) id<VSuggestedPersonCollectionViewCellDelegate> delegate;

@end
