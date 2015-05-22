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
 *  Stream cells that conform to this protcol desire specialization. When a cell or cell
 *  component becomes specialized it constructs a view hierarchy and lays itself out in a
 *  configuration that can be shared among sequences that result in the same specialization.
 *  A specialized cell should only be reused to represent another sequence with the same 
 *  conditions that it is initially configured with. In order to achieve this,
 *  the stream collection cell should return a unique identifier from
 *  "reuseIdentifierForSequence:baseIdentifier" for each specialization.
 */
@protocol VStreamCellComponentSpecialization <NSObject>

/**
 *  An identifier that represents the specialization of a cell or cell component to minimize 
 *  relayout or reconfiguration when reused.
 */
+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier;

@end
