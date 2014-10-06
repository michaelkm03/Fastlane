//
//  VSuggestedPersonCollectionViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSuggestedPersonData : NSObject

@property (nonatomic, strong) NSNumber *remoteId;
@property (nonatomic, strong) NSNumber *numberOfFollowers;
@property (nonatomic, assign) BOOL isMainUserFollowing;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *pictureUrl;

@end

@protocol VSuggestedPersonCollectionViewCellDelegate

@required
- (void)unfollowPerson:(VSuggestedPersonData *)userData;
- (void)followPerson:(VSuggestedPersonData *)userData;

@end

@interface VSuggestedPersonCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) VSuggestedPersonData *data;

+ (UIImage *)followedImage;
+ (UIImage *)followImage;

@property (nonatomic, weak) id<VSuggestedPersonCollectionViewCellDelegate> delegate;

@end
