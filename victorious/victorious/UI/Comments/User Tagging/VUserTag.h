//
//  VUserTag.h
//  victorious
//
//  Created by Sharif Ahmed on 2/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTag.h"

@interface VUserTag : VTag

/**
 Create a new tag with the given displayString, databaseFormattedString, and tag string attributes. NOTE: USE CLASS DECLARATIONS INSTEAD, this is only for internal use and subclassing.
 
 @param displayString the attributed string that will serve as the "displayString" property of this tag
 @param databaseFormattedString the attributed string that will serve as the "displayString" property of this tag
 @param remoteId the NSNumber that will serve as the "remoteId" property of this tag
 @param tagStringAttributes the attributed string that will serve as the "displayString" property of this tag
 
 @return a new VTag containing the given displayString, databaseFormattedString, and tagStringAttributes
 */
- (instancetype)initWithDisplayString:(NSString *)displayString
              databaseFormattedString:(NSString *)databaseFormattedString
                             remoteId:(NSNumber *)remoteId
               andTagStringAttributes:(NSDictionary *)tagStringAttributes;

/**
 The remoteId of the user found when parsing the tag.
 */
@property (nonatomic, readonly) NSNumber *remoteId;

@end
