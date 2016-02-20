//
//  VStreamHeaderTimeSince.h
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VSequence;

/**
 *  A Stream header view for displaying information about a sequence. 
 *  It displays a user profile button, a creation info container 
 *  (containing username and any reposted remixed info) and a time 
 *  since label or follow control that is right justified.
 */
@interface VStreamCellHeader : UIView <VHasManagedDependencies>

/**
 *  The sequence for this header to represent.
 */
@property (nonatomic, strong) VSequence *sequence;

@property (nonatomic, strong, readwrite) NSString *sourceScreenName;

@end
