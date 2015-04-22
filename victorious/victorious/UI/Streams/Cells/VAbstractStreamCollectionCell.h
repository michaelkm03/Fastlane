//
//  VAbstractStreamCollectionCell.h
//  victorious
//
//  Created by Michael Sena on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VSequence;

@interface VAbstractStreamCollectionCell : VBaseCollectionViewCell

/**
 *  Return an identifier that will minimize the amount of view hierarchy setup
 *  and layout calculations that need to occur when a new cell comes on screen. 
 *  
 *  For example an image post and poll post should be separate identifiers so
 *  that the content view (imageView or pollView) will only have to undergo
 *  setup/layout once.
 *  
 *  Abstract method. Should be overriden by concrete subclasses.
 */
+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence;

@end
