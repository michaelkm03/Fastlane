//
//  VSuggestedPersonCollectionViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSuggestedPersonData : NSObject

@property (nonatomic, assign) NSInteger remoteId;
@property (nonatomic, assign) NSUInteger numberOfFollowers;
@property (nonatomic, assign) BOOL isMainUserFollowing;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *pictureUrl;

@end

@interface VSuggestedPersonCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) VSuggestedPersonData *data;

+ (UIImage *)followedImage;
+ (UIImage *)followImage;

- (IBAction)onFollow:(id)sender;

@end
