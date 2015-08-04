//
//  VObjectManager+VTemplateDownloaderConformance.h
//  victorious
//
//  Created by Josh Hinman on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VTemplateDownloadOperation.h"

/**
 Adds VTemplateDownloader protocol conformance to VObjectManager
 */
@interface VObjectManager (VTemplateDownloaderConformance) <VTemplateDownloader>

@end
