//
//  VNotificationSettings+RestKit.m
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettings+RestKit.h"

@implementation VNotificationSettings (RestKit)

+ (NSString *)entityName
{
    return @"NotificationSettings";
}

+ (RKEntityMapping *)entityMapping
{
    NSDictionary *propertyMap = @{
                                  @"notification_creator_post"       : VSelectorName(isPostFromCreatorEnabled),
                                  @"notification_follow_post"        : VSelectorName(isNewFollowerEnabled),
                                  @"notification_comment_post"       : VSelectorName(isNewPrivateMessageEnabled),
                                  @"notification_private_message"    : VSelectorName(isNewCommentOnMyPostEnabled),
                                  @"notification_new_follower"       : VSelectorName(isPostFromFollowedEnabled)
                                  };
    
    RKEntityMapping *mapping = [RKEntityMapping
                                mappingForEntityForName:[self entityName]
                                inManagedObjectStore:[RKObjectManager sharedManager].managedObjectStore];
    
    [mapping addAttributeMappingsFromDictionary:propertyMap];
    
    return mapping;
}

+ (NSArray *)descriptors
{
    return @[ [RKResponseDescriptor responseDescriptorWithMapping:[self entityMapping]
                                                           method:RKRequestMethodAny
                                                      pathPattern:@"/api/device/preferences"
                                                          keyPath:@"payload"
                                                      statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
}

- (NSDictionary *)parametersDictionary
{
    [self replaceNilValuesWithDefaults];
    
    return @{
             @"notification_creator_post"       : self.isPostFromCreatorEnabled,
             @"notification_follow_post"        : self.isNewFollowerEnabled,
             @"notification_comment_post"       : self.isNewPrivateMessageEnabled,
             @"notification_private_message"    : self.isNewCommentOnMyPostEnabled,
             @"notification_new_follower"       : self.isPostFromFollowedEnabled
             };
}

- (void)replaceNilValuesWithDefaults
{
    self.isPostFromCreatorEnabled = self.isPostFromCreatorEnabled ?: @NO;
    self.isNewFollowerEnabled = self.isNewFollowerEnabled ?: @NO;
    self.isNewPrivateMessageEnabled = self.isNewPrivateMessageEnabled ?: @NO;
    self.isNewCommentOnMyPostEnabled = self.isNewCommentOnMyPostEnabled ?: @NO;
    self.isPostFromFollowedEnabled = self.isPostFromFollowedEnabled ?: @NO;
}

@end
