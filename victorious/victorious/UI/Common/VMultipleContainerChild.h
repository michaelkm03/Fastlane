//
//  VMultipleContainerChild.h
//  victorious
//
//  Created by Patrick Lynch on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VMultipleContainerChild;

@protocol VMultipleContainer <NSObject>

@property (nonatomic, readonly) NSArray *children;

- (void)selectChild:(id<VMultipleContainerChild>)child;

@end

@protocol VMultipleContainerChildDelegate <NSObject>

/**
 A conforming object should return the navigtation item of the view controller that is
 the parent in the view controller hierarchy, specifically one whose `navigationItem`
 is being displayed in its navigation bar.  The expectation is taht setting properties of
 thie UINavigationItem instance return in this method will make visible updates.
 */
- (UINavigationItem *)parentNavigationItem;

@end

@protocol VMultipleContainerChild <NSObject>

/**
 Called by VMultipleContainer on its child view controllers when
 they are selected from user input or programmatically.
 
 @param isDefault Indicates whether the selection was the first selection, i.e.
 the default child view controller to show.  This will happen once per instantation
 and load of the VMultipleContainer instance.
 */
- (void)multipleContainerDidSetSelected:(BOOL)isDefault;

@property (nonatomic, weak) id<VMultipleContainerChildDelegate> multipleContainerChildDelegate;

@end
