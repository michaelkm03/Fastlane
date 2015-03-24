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

/**
 Creates a new appInfo object from the provided dependencyManager. After creation, all owner and app properties (such as name, profile image url, etc...) found on the dependencyManager will be available via the properties of this class.
 
 @param dependencyManager The dependency manager that should be searched for owner and app properties. Given the inheiriting nature of the dependencyManager class and the level of the app / owner properties (which are payload-level), you should be safe to init this with the dependency manager in whatever class you're currently in.
 
 @return A new AppInfo object containing all found information about the user and app as outlined by the properties below.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) NSString *ownerName;
@property (nonatomic, readonly) NSString *ownerId;
@property (nonatomic, readonly) NSURL *profileImageURL;
@property (nonatomic, readonly) NSString *appName;
@property (nonatomic, readonly) NSURL *appURL;

@end
