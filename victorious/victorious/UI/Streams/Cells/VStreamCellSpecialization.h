//
//  VStreamCellSpecialization.h
//  victorious
//
//  Created by Michael Sena on 5/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

/**
 *  Stream cells that conform to this protcol desires specialization. When a cell is 
 *  specialized it is constructs a view hierarchy and layout for particular conditions 
 *  on a sequence. A specialized cell should only be reused to represent another sequence 
 *  with the same conditions that it is initially configured with. In order to achieve this, 
 *  the stream collection cell should return a unique identifier from
 *  "reuseIdentifierForSequence:baseIdentifier" for each specialization.
 */
@protocol VStreamCellComponentSpecialization <NSObject>

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier;

@end
