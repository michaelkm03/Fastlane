//
//  VObjectManager+AlertTesting.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VObjectManager+AlertTesting.h"
#import "VObjectManager+Private.h"

@implementation VObjectManager (AlertTesting)

- (RKManagedObjectRequestOperation *)registerTestAlert:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    NSDictionary *parameters = @{@"description" : @"You've unlocked more gifts"};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return [self POST:@"/api/alert/create"
               object:nil
           parameters:@{@"type" : @"level", @"params" : jsonString}
         successBlock:success
            failBlock:fail];
}

- (RKManagedObjectRequestOperation *)acknowledgeAlert:(NSString *)alertID
                                          withSuccess:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail
{
    return [self POST:@"/api/alert/acknowledge"
               object:nil
           parameters:@{@"alert_id" : alertID}
         successBlock:success
            failBlock:fail];
}

@end
