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

@protocol VEditableTextPostViewControllerDelegate <NSObject, VTextListener>

- (void)textPostViewController:(VEditableTextPostViewController *)textPostViewController didDeleteHashtags:(NSArray *)deletedHashtags;

- (void)textPostViewController:(VEditableTextPostViewController *)textPostViewController didAddHashtags:(NSArray *)addedHashtags;

@end


@interface VEditableTextPostViewController : VTextPostViewController <VHasManagedDependencies>

@property (nonatomic, weak) id<VEditableTextPostViewControllerDelegate> delegate;

@property (nonatomic, readonly) NSString *textOutput;

- (BOOL)addHashtag:(NSString *)hashtagText;

- (BOOL)removeHashtag:(NSString *)hashtagText;

@end
