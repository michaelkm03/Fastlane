//
//  VUserSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VUserSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 A context for this search.
 
 Acceptable Values:
 VObjectManagerSearchContextMessage: A search context for finding messagable users
 VObjectManagerSearchContextUserTag: A search context for finding taggable users
 VObjectManagerSearchContextDiscover: A search context for the discover user search
 
 Defaults to: VObjectManagerSearchContextDiscover
 */
@property (nonatomic, strong) NSString *searchContext;
@property (nonatomic, strong) NSMutableDictionary *messageViewControllers;

@end
