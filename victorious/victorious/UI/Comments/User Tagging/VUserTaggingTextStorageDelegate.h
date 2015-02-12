//
//  VUserTaggingTextStorageDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 2/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VUserTaggingTextStorage, VUser, VInlineSearchTableViewController;

@protocol VUserTaggingTextStorageDelegate <NSTextStorageDelegate>

/**
 The UserTaggingTextStorage has recognized a search string and wants to show
 a view controller to display results of the search
 */
- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToShowViewController:(UIViewController *)viewController;

/**
 The UserTaggingTextStorage has recognized a search string and wants to show
 a view controller to display results of the search
 */
- (void)userTaggingTextStorage:(VUserTaggingTextStorage *)textStorage wantsToDismissViewController:(UIViewController *)viewController;

@end
