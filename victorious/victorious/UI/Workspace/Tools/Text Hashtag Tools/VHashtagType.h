//
//  VHashtagType.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VWorkspaceTool.h"

@interface VHashtagType : NSObject <VWorkspaceTool>

- (instancetype)initWithHashtagText:(NSString *)hashtagText isDefault:(BOOL)isDefault;

@property (nonatomic, assign, readonly) BOOL isDefault;
@property (nonatomic, strong, readonly) NSString *hashtagText;

@end
