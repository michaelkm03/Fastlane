//
//  VTextPostViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VTextPostViewController;

@protocol VTextPostViewControllerDelegate <NSObject>

- (void)textPostViewController:(VTextPostViewController *)textPostViewController didDeleteHashtags:(NSArray *)deletedHashtags;

@end

@interface VTextPostViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign, getter=isEditable) BOOL editable;

@property (nonatomic, weak) id<VTextPostViewControllerDelegate> delegate;

- (void)addHashtag:(NSString *)hashtagText;

- (void)removeHashtag:(NSString *)hashtagText;

- (void)startEditingText;

@end
