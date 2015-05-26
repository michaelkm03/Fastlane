//
//  VTextPostCallout.h
//  victorious
//
//  Created by Patrick Lynch on 5/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM( NSInteger, VTextCalloutType )
{
    VTextCalloutTypeURL,
    VTextCalloutTypeHashtag,
};

@interface VTextPostCallout : NSObject

@property (nonatomic, strong, readonly) NSString *text; ///< The text of the callout
@property (nonatomic, assign, readonly) NSRange range; ///< The range of the callout in the text from which it came
@property (nonatomic, assign, readonly) VTextCalloutType type; ///< The type of callout, necessary for responding properly when tapped

@end

@interface VTextPostCalloutHelper : NSObject

/**
 Returns an array of NSValues containing ranges for each of the callouts for the specified
 text.  This method internally calls `calloutsForText:` to get the callouts for the text.
 Those callouts may be generated if they do not exist in the cache already.
 */
- (NSArray *)calloutRangesForText:(NSString *)text;

/**
 Returns the cached callouts for the specified text.  If already created once before using
 the same text, the cached value will be returned.  Otherwise new callouts will generated
 and cached, then returned.
 */
- (NSDictionary *)calloutsForText:(NSString *)text;

@end
