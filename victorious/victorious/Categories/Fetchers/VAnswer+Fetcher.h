//
//  VAnswer+Fetcher.h
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAnswer.h"

@interface VAnswer (Fetcher)

/**
 *  Wraps MediaURL in a urlWithString:
 */
- (NSURL *)previewMediaURL;

@end
