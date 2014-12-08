//
//  VVoteSettings.h
//  victorious
//
//  Created by Patrick Lynch on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VVoteSettingsDidUpdateNotification;
extern NSString * const VVoteSettingsDidUpdateKeyVoteType;

@interface VVoteSettings : NSObject

@property (nonatomic, strong) NSArray *voteTypes;

@end
