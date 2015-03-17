//
//  VDiscoverViewControllerProtocol.h
//  victorious
//
//  Created by Patrick Lynch on 10/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

/**
 A protocol that defines some properties required to effictively manage state
 in data-driven table view controllers.
 // TODO: If state management gets any more complex, implement an enum with specific states listed.
 */
@protocol VDiscoverViewControllerProtocol <NSObject>

@required

/**
 View Controllers should return YES if an error has occured while loading data or the
 response returned with no results.  In either case, it will be handled in such a way
 that displays a different table view cell.
 */
@property (nonatomic, readonly) BOOL isShowingNoData;

/**
 This property will be NO by default, which lets the view controller know that even
 though there is no data (yet), there is not yet any need to show an error or empty state.
 View controllers should set this to YES after the first time a response from the server
 has occurred -- whether it was successful or not.
 */
@property (nonatomic, assign) BOOL hasLoadedOnce;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Requests that the view controller reload its data from the server.
 
 @param shouldClearCurrentContent Whether or not any existing content should be clear
 and the view controller restored to its loading state.
 */
- (void)refresh:(BOOL)shouldClearCurrentContent;

@end
