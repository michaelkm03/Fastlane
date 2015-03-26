//
//  VTextPostViewController.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@interface VTextPostViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) NSString *text;

- (void)startEditingText;

@end
