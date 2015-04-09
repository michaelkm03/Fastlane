//
//  VDownloadManager.h
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDownloadTaskInformation;

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 */
typedef void (^VDownloadManagerTaskCompleteBlock)(NSURL *downloadFileLocation, NSError *error);
typedef void (^VDownloadManagerTaskProgressBlock)(CGFloat progress);

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 *
 *  This has not been fully engineered for general use. Only supports one download task at a time.
 *
 */
@interface VDownloadManager : NSObject

/**
 *  ATTENTION: FOR DEMO PURPOSES ONLY
 */
- (void)enqueueDownloadTask:(VDownloadTaskInformation *)downloadTask
               withProgress:(VDownloadManagerTaskProgressBlock)taskProgress
                 onComplete:(VDownloadManagerTaskCompleteBlock)taskCompletion;

@end
