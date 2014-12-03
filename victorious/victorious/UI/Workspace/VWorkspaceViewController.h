//
//  VWorkspaceViewController.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

typedef void (^VWorkspaceCompletion)(BOOL finished, UIImage *previewImage);

@interface VWorkspaceViewController : UIViewController <VHasManagedDependancies>

@property (nonatomic, copy) VWorkspaceCompletion completionBlock;

@end
