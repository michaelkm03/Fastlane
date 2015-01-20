//
//  VAsset+VFetcher.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAsset.h"

@interface VAsset (Fetcher)

/**
 *  Convenience accessor for the data url.
 */
- (NSURL *)dataURL;

@end
