//
//  VSuggestedPeopleCollectionViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VDiscoverViewControllerProtocol.h"

@class VUser;

@protocol VSuggestedPeopleCollectionViewControllerDelegate <NSObject>

- (void)suggestedPeopleDidFailToLoad;
- (void)suggestedPeopleDidFinishLoading;
- (void)didAttemptActionThatRequiresLogin;

@end

@interface VSuggestedPeopleCollectionViewController : UICollectionViewController <VDiscoverViewControllerProtocol>

+ (VSuggestedPeopleCollectionViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

- (void)refresh;

@property (nonatomic, weak) id<VSuggestedPeopleCollectionViewControllerDelegate> delegate;

@property (nonatomic, strong) NSError *error;
@property (nonatomic, readonly, strong) NSArray *suggestedUsers;

@end
