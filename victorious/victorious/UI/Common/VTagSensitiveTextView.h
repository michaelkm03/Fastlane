//
//  VTagSensitiveTextView.h
//  victorious
//
//  Created by Sharif Ahmed on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTagSensitiveTextViewDelegate.h"

@class VTagDictionary;

@interface VTagSensitiveTextView : UITextView

/**
    Finds tags in the supplied text, sets the attributed string of the textView, applies the supplied tagAttributes to found tags and defaultAttributes to the rest of the string, and sets the tagTapDelegate to respond to tag touch events (if non-nil)

    @param databaseFormattedText the database-formatted text that could contain tags that should be formatted for display
    @param tagAttributes the string attributes that should be applied to found tags
    @param defaultAttibutes the string attributes that should be applied to parts of the string that are not tags
    @param tagTapDelegate the delegate that will respond to tag-touch events
 */
- (void)setupWithDatabaseFormattedText:(NSString *)databaseFormattedText
                         tagAttributes:(NSDictionary *)tagAttributes
                     defaultAttributes:(NSDictionary *)defaultAttributes
                     andTagTapDelegate:(id<VTagSensitiveTextViewDelegate>)tagTapDelegate;

/**
 Finds tags in the supplied text, applies the supplied tagAttributes to found tags and defaultAttributes to the rest of the string, and returns the found tags and display-ready string to the completion block. This block executes synchronously.
 
 @param databaseFormattedText the database-formatted text that could contain tags that should be formatted for display
 @param tagAttributes the string attributes that should be applied to found tags
 @param defaultAttibutes the string attributes that should be applied to parts of the string that are not tags
 @param completionBlock the block that will recieve a VTagDictionary of found tags and an NSAttributed string of the display-ready string after formatting is complete
 */
+ (void)displayFormattedStringFromDatabaseFormattedText:(NSString *)databaseFormattedText
                                          tagAttributes:(NSDictionary *)tagAttributes
                                   andDefaultAttributes:(NSDictionary *)defaultAttributes
                                        toCallbackBlock:(void (^)(VTagDictionary *foundTags, NSAttributedString *displayFormattedString))completionBlock;

@property (nonatomic, readonly) NSDictionary *tagStringAttributes; ///< Attributes that will be applied to the display version of the tag text
@property (nonatomic, weak) id <VTagSensitiveTextViewDelegate> tagTapDelegate; ///< The delegate that will recieve tag tap messages
@property (nonatomic, readonly) VTagDictionary *tagDictionary; ///< The tag dictionary representing all found tags

@end
