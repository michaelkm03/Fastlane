//
//  VDownloadManager.h
//  victorious
//
//  Created by Michael Sena on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDownloadTaskInformation;

typedef void (^VDownloadManagerTaskCompleteBlock)(NSURL *downloadFileLocation, NSURLResponse *response, NSError *error);

@interface VDownloadManager : NSObject

- (void)enqueueDownloadTask:(VDownloadTaskInformation *)downloadTask
                 onComplete:(VDownloadManagerTaskCompleteBlock)completion;

@end
