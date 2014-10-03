//
//  VContentCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VContentCell : VBaseCollectionViewCell

@property (nonatomic, strong) NSArray *animationSequence;
@property (nonatomic, assign) NSTimeInterval animationDuration;

- (void)playAnimation;

@end
