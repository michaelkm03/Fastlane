//
//  VContentViewFactory.h
//  victorious
//
//  Created by Josh Hinman on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>

@class VSequence, ContentViewContext;

/**
 Instantiates either a VNewContentViewController or a 
 VWebContentViewController, depending on the type of 
 sequence.
 */
@interface VContentViewFactory : NSObject <VHasManagedDependencies>

/**
 Initializes a new instance of the content view factory with the given dependency manager.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 Checks to make sure the specified sequence is capable of being displayed.
 
 @param reason If the return value is NO, this string is set to a user-friendly explanation of why we can't display the sequence.
 
 @return YES if calling -contentViewForSequence:commentID:placeholderImage: and passing this sequence will be successful.
 */
- (BOOL)canDisplaySequence:(VSequence *)sequence localizedReason:(NSString **)reason;

/**
 Instantiates and returns a content view primed to display the given sequence in the provided context.
 */
- (UIViewController *)contentViewForContext:(ContentViewContext *)context;

/**
 Instantiates and returns a web browser content view to display the specified URL.
 Calling code is responding for presenting, this method only creates the view controller.
 */
- (UIViewController *)webContentViewControllerWithURL:(NSURL *)url;

@end

#pragma mark -

@interface VDependencyManager (VContentViewFactory)

/**
 Creates a new VContentViewFactory instance based on this dependency manager's configuration
 */
- (VContentViewFactory *)contentViewFactory;

- (VDependencyManager *)contentViewDependencyManager;

@end
