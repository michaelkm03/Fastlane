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

@class VSequence;

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

/**
 Instantiates and returns a content view primed to display the given
 sequence. If the sequence contains a deeplink to another app, this
 method returns nil and -[UIApplication openURL:] will be called.
 
 @param sequence          The sequence to display
 @param placeHolderImage  An image, typically the sequence's thumbnail, that can be displayed
                          in the place of content while the real thing is being loaded
 @param comment           A comment ID to scroll to and highlight, typically used when content view
                          is being presented when the app is launched with a deep link URL.  If there
                          is no comment, simply pass `nil`.
 */
- (UIViewController *)contentViewForSequence:(VSequence *)sequence commentID:(NSNumber *)commentID placeholderImage:(UIImage *)placeholderImage;

@end

#pragma mark -

@interface VDependencyManager (VContentViewFactory)

/**
 Creates a new VContentViewFactory instance based on this dependency manager's configuration
 */
- (VContentViewFactory *)contentViewFactory;

@end