//
//  VAppOwner.h
//  victorious
//
//  Created by Sharif Ahmed on 3/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VAppInfo : NSObject

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSURL *appURL;

@end
