//
//  VImageVideoLibraryViewController.h
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

@interface VImageVideoLibraryViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, copy) void (^userSelectedCamera)();

@property (nonatomic, copy) void (^userSelectedSearch)();

@end
