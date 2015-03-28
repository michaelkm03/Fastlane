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

@protocol VEditableTextPostViewControllerDelegate <NSObject>

- (void)textPostViewController:(VTextPostViewController *)textPostViewController didDeleteHashtags:(NSArray *)deletedHashtags;

@end

@interface VEditableTextPostViewController : VTextPostViewController <VHasManagedDependencies>

@property (nonatomic, weak) id<VEditableTextPostViewControllerDelegate> delegate;

- (void)addHashtag:(NSString *)hashtagText;

- (void)removeHashtag:(NSString *)hashtagText;

- (void)startEditingText;

@end
