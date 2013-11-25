//
//  VAppDelegate.h
//  victoriOS
//
//  Created by Will Long on 11/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
