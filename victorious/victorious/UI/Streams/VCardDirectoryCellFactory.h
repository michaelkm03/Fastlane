//
//  VCardDirectoryCellFactory.h
//  victorious
//
//  Created by Sharif Ahmed on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDirectoryCellFactory.h"

/**
    This factory provides sizing and collection view registration for VCardDirectoryCells and VCardSeeMoreDirectoryCells.
    If used, the sizing functions of this factory will display cells sized such that they show in 2 columns.
 */
@interface VCardDirectoryCellFactory : NSObject <VDirectoryCellFactory>

@end
