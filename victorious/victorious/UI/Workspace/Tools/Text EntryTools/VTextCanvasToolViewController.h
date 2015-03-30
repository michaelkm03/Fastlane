//
//  VTextCanvasToolViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VEditableTextPostViewController;

@interface VTextCanvasToolViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong, readonly) VEditableTextPostViewController *textPostViewController;

- (void)setImageControlsVisible:(BOOL)visible animated:(BOOL)animated;

@end
