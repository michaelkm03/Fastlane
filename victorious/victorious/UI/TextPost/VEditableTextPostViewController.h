//
//  VEditableTextPostViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTextPostViewController.h"
#import "VHasManagedDependencies.h"
#import "VTextListener.h"

@class VEditableTextPostViewController;

/**
 A delegate for responding to changes in a VEditableTextPostViewController,
 mostly related to adding or removing hastags while editing the text of the text post.
 */
@protocol VEditableTextPostViewControllerDelegate <NSObject, VTextListener>

/**
 Called when the user removes a hashtag during text editing in an in-progress text post.
 */
- (void)textPostViewController:(VEditableTextPostViewController *)textPostViewController didDeleteHashtags:(NSArray *)deletedHashtags;

/**
 Called when the user adds a hashtag during text editing in an in-progress text post.
 */
- (void)textPostViewController:(VEditableTextPostViewController *)textPostViewController didAddHashtags:(NSArray *)addedHashtags;

@end

/**
 An editable version of VTextPostViewController, which provides the layout and styling
 for text posts by does not offer any ability to edit the text.  This class provides the editable
 functionality with support for embedding hashtags while the user types them out or 
 manually/programmatically from some other source, such as a list of trending hashtsgs.
 */
@interface VEditableTextPostViewController : VTextPostViewController <VHasManagedDependencies>

@property (nonatomic, weak) id<VEditableTextPostViewControllerDelegate> delegate;

/**
 The final output of the text post in its current state, inluding embedded hashtags
 and excluding any placeholder text.  Use this to check if content is publishable
 (such as meeting the minumym and maximum length requirements) and for reading
 the final output before sending to the sever.
 */
@property (nonatomic, readonly) NSString *textOutput;

/**
 Triggers the text view to become or resign first responder and updates internal
 state to reflect the appearance of the keybaord and prepare for user input.
 */
@property (nonatomic, assign) BOOL isEditing;

/**
 Programmatically embed a hashtag in the text at the currently selelected range.
 */
- (BOOL)addHashtag:(NSString *)hashtagText;

/**
 Programmatically remnove a hashtag from the text being edited.
 */
- (BOOL)removeHashtag:(NSString *)hashtagText;

@end
