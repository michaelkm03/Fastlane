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

- (instancetype)initWithString:(NSString *)str
                      textView:(UITextView *)textView
               taggingDelegate:(id<VUserTaggingTextStorageDelegate>)taggingDelegate;

/**
 Create a database-formatted version of the current attributed string
 IMPORTANT: this will return nil if the textView property is nil
 */
- (NSString *)databaseFormattedString;

@property (nonatomic, weak) id <VUserTaggingTextStorageDelegate> taggingDelegate;
@property (nonatomic, weak) VDependencyManager *dependencyManager;
@property (nonatomic, weak) UITextView *textView;

@end
