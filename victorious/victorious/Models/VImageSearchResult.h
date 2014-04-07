//
//  VImageSearchResult.h
//  victorious
//
//  Created by Josh Hinman on 4/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VImageSearchResult : NSObject

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) NSURL    *thumbnailURL;
@property (nonatomic, strong) NSURL    *sourceURL;

@end
