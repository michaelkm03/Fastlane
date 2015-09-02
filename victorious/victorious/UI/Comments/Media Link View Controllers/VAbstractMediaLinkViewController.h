//
//  VAbstractMediaLinkViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCommentMediaType.h"

/**
    A block that should be provided the aspect ratio of content loaded from the mediaUrlString.
 */
typedef void (^MediaLoadingCompletionBlock) (CGFloat contentAspectRatio);

/**
    The abstract base class for a view controller that displays a simple, rotation and
        variable-aspect-ratio -friendly view around a piece of content.
 */
@interface VAbstractMediaLinkViewController : UIViewController

/**
    Factory method for creating the proper media link view controller class for the provided url and linkType.
 
    @param url The url that media should be loaded from. Must not be nil.
    @param linkType The kind of media present at the url represented by the urlString.
 
    @return A VAbstractMediaLinkViewController subclass that will be able to display the loaded media appropriately or
                a VImageMediaLinkViewController if an unrecognized linkType is provided.
 */
+ (instancetype)newWithMediaUrl:(NSURL *)url andMediaLinkType:(VCommentMediaType)linkType;

/**
    Sets the mediaUrl property and default value of the contentAspectRatio. Expected to
        be overridden by subclasses which should also call the superclass implementation.
 
    @param url The url that media should be loaded from. Must not be nil.
 
    @return A VAbstractMediaLinkViewController.
 */
- (instancetype)initWithUrl:(NSURL *)url NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
    The url that media should be loaded from.
 */
@property (nonatomic, readonly) NSURL *mediaUrl;

/**
    The view containing the view that will display media. Subclasses should add the
        view that will display media as a subview of this view with fit to parent constraints.
 */
@property (nonatomic, weak, readonly) IBOutlet UIView *contentContainerView;

/**
    The current aspect ratio of the content. This is set by the completionBlock of loadMediaWithCompletionBlock:.
 */
@property (nonatomic, readonly) CGFloat contentAspectRatio;

@end

@interface VAbstractMediaLinkViewController (SubclassOverrides)

/**
    MUST be overridden by subclasses. Subclass implementations should load the media from
        their instance's mediaUrlString and then call the completion block, providing
        the aspect ratio of the downloaded content.
 
    @param completionBlock A block that should be provided the aspect ratio of the loaded media.
                            Calling this block will stop the activity indicator and resize the content
                            view as needed.
 */
- (void)loadMediaWithCompletionBlock:(MediaLoadingCompletionBlock)completionBlock;

@end