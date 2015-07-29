//
//  VContentViewPresenter.h
//  victorious
//
//  Created by Tian Lan on 7/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;
@class VDependencyManager;

/**
 A helper presenter class that helps VStreamCollectionViewController
 or VScaffoldViewController to present a VNewContentView
 */
@interface VContentViewPresenter : NSObject

/**
 Presents a content view for the specified VSequence object.
 
 @param viewController the view controller from where the presentation message was sent
 @param placeHolderImage An image, typically the sequence's thumbnail, that can be displayed
 in the place of content while the real thing is being loaded
 @param comment A comment ID to scroll to and highlight, typically used when content view
 is being presented when the app is launched with a deep link URL.  If there
 is no comment, simply pass `nil`.
 */
+ (void)presentContentViewFromViewController:(UIViewController *)viewController
                       withDependencyManager:(VDependencyManager *)dependencyManager
                                 ForSequence:(VSequence *)sequence
                              inStreamWithID:(NSString *)streamId
                                   commentID:(NSNumber *)commentID
                            withPreviewImage:(UIImage *)previewImage;

@end
