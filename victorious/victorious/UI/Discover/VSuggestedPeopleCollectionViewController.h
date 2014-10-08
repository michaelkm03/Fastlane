//
//  VSuggestedPeopleCollectionViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser;

@protocol VSuggestedPeopleCollectionViewControllerDelegate <NSObject>

- (void)didFailToLoad;
- (void)didFinishLoading;

@end

@interface VSuggestedPeopleCollectionViewController : UICollectionViewController

+ (VSuggestedPeopleCollectionViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

- (void)refresh;

@property (nonatomic, weak) id<VSuggestedPeopleCollectionViewControllerDelegate> delegate;

@property (nonatomic, readonly) BOOL isShowingNoData;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSArray *suggestedUsers;

@end
