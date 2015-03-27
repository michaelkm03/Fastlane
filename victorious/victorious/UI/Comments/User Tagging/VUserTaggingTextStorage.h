//
//  VUserTaggingTextStorage.h
//  victorious
//
//  Created by Josh Hinman on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUserTaggingTextStorageDelegate.h"

@class VDependencyManager;

/**
 An NSTextStorage subclass that supports
 searching and tagging users.
 */
@interface VUserTaggingTextStorage : NSTextStorage

/**
 Initialize a new VUserTaggingTextStorage with the given textView, default string font, and tagging delegate.
 This function will automatically display-format the string in the textView. Font is required, other parameters are optional.
 
 @param textView The UITextView who's text should be formatted and who's cursor should be moved around as tags are created / deleted
 @param font The font to apply to non-tag strings
 @param taggingDelegate The VUserTaggingTextStorageDelegate that will recieve tag touch events
 
 @return a new VUserTaggingTextStorage instance that is managing the given textView
 */
- (instancetype)initWithTextView:(UITextView *)textView
                     defaultFont:(UIFont *)defaultFont
                 taggingDelegate:(id<VUserTaggingTextStorageDelegate>)taggingDelegate;

/**
 Create a database-formatted version of the current attributed string
 IMPORTANT: this will return nil if the textView property is nil
 */
- (NSString *)databaseFormattedString;

@property (nonatomic, weak) id <VUserTaggingTextStorageDelegate> taggingDelegate;
@property (nonatomic, weak) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, assign) BOOL disableSearching;
@property (nonatomic, strong) UIFont *defaultFont;

@end
