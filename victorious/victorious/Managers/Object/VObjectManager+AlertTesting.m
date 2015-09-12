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
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger testLevel = [ud integerForKey:@"levelNumber"] ?: 1;
    [ud setInteger:testLevel + 1 forKey:@"levelNumber"];
    [ud synchronize];
    
    NSDictionary *parameters = @{@"level" : @{@"number" : @(testLevel)},
                                 @"backgroundVideo" : @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/b918ccb92d5040f754e70187baf5a765/playlist.m3u8",
                                 @"title" : @"YEAH!!",
                                 @"description" : @"You won new stuff!",
                                 @"icons" : @[ @"http://unrestrictedstock.com/wp-content/uploads/transportation-icons-rocket-space-ship-launch-shuttle.jpg" ],
                                 @"type" : @"levelUp"
                                 };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return [self POST:@"/api/alert/create"
               object:nil
           parameters:@{@"type" : @"level", @"params" : jsonString}
         successBlock:success
            failBlock:fail];
}

@end
