//
//  VTemplateSerialization.h
//  victorious
//
//  Created by Josh Hinman on 4/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 De-serializes template data received from the server into an
 NSDictionary suitable for initializing VDependencyManager.
 */
@interface VTemplateSerialization : NSObject

+ (NSDictionary *)templateConfigurationDictionaryWithData:(NSData *)data;

@end
