//
//  Sequence+RestKit.m
//  victoriOS
//
//  Created by Will Long on 11/27/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VAppDelegate.h"
#import "Sequence+RestKit.h"

@implementation Sequence (RestKit)
/*
+(void)loadWithRestKit
{
    // Load the public Gists from Github
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Sequence" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"id":             @"gistID",
                                                        @"url":            @"jsonURL",
                                                        @"description":    @"descriptionText",
                                                        @"public":         @"public",
                                                        @"created_at":     @"createdAt"}];
    
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping pathPattern:@"/gists/public" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/gists/public"]];
    RKManagedObjectRequestOperation *managedObjectRequestOperation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    managedObjectRequestOperation.managedObjectContext = [VAppDelegate sharedAppDelegate].managedObjectContext;
    [[NSOperationQueue currentQueue] addOperation:managedObjectRequestOperation];
}
*/
@end
