//
//  VImageAssetDownloader.h
//  victorious
//
//  Created by Michael Sena on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAssetDownloader.h"

@import Photos;

/**
 *  Errors generated by this class will be in this domain.
 */
extern NSString * const VImageAssetDownloaderErrorDomain;

/**
 *  VImageAssetDownlaoder downloads images assets and placed them in the temporary directory.
 */
@interface VImageAssetDownloader : VAssetDownloader

@end