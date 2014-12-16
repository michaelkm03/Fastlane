//
//  VVoteSettings.h
//  victorious
//
//  Created by Patrick Lynch on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVoteType;

@interface VVoteSettings : NSObject

@property (nonatomic, strong) NSArray *voteTypes;

- (VVoteType *)voteTypeWithProductIdentifier:(NSString *)productIdentifier;

@end
