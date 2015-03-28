//
//  VTextPostViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VTextPostViewModel;

@interface VTextPostViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) NSString *text;

@property (nonatomic, readonly) UITextView *textView;

@property (nonatomic, strong, readonly) IBOutlet VTextPostViewModel *viewModel;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
