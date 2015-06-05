//
//  VEndCard+Fetcher.h
//  victorious
//
//  Created by Patrick Lynch on 5/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCard.h"
#import "VSequencePermissions.h"

@interface VEndCard (Fetcher)

@property (nonatomic, readonly) VSequencePermissions *permissions;

@end
