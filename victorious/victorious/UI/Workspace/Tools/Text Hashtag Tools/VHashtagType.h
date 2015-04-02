//
//  VHashtagType.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

/**
 A workspace tool that represents a hashtag option from a picker menu.
 */
@interface VHashtagType : NSObject <VWorkspaceTool>

- (instancetype)initWithHashtagText:(NSString *)hashtagText;

/**
 The text of the hashtag.
 */
@property (nonatomic, strong, readonly) NSString *hashtagText;

@end
