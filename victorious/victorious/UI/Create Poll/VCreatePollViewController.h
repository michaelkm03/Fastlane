//
//  VCreatePollViewController.h
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VCreatePollViewController;

/**
 A completion result passed in the completion handler.
 */
typedef NS_ENUM(NSInteger, VCreatePollViewControllerResult)
{
    VCreatePollViewControllerResultCancelled,
    VCreatePollViewControllerResultDone
};

/**
 A completion handler typedef for informing consumers of completion.
 */
typedef void (^VCreatePollViewControllerCompletionHandler)(VCreatePollViewControllerResult result);

/**
 A UIViewController for creating polls.
 */
@interface VCreatePollViewController : UIViewController

/**
 A convenience factory method.
 */
+ (instancetype)newCreatePollViewController;

/**
 Specify a block to be called whe the user is done.
 */
@property (nonatomic, copy) VCreatePollViewControllerCompletionHandler completionHandler;

@end
