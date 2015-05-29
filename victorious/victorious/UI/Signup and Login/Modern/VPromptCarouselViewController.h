//
//  VPromptCarouselViewController.h
//  victorious
//
//  Created by Michael Sena on 5/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

/**
 *  Pass the landingViewControllers dependency manager to this carousel and it will 
 *  grab the appropriate prompt strings, fonts and colors.
 */
@interface VPromptCarouselViewController : UIViewController <VHasManagedDependencies>

@end
