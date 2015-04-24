//
//  VHermesActionView.h
//  victorious
//
//  Created by Michael Sena on 4/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractActionView.h"

#import "VHasManagedDependencies.h"

@class VSequence;

@interface VHermesActionView : VAbstractActionView <VHasManagedDependencies>

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier;

@end
