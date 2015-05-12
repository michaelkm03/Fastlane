//
//  VSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VStreamCellSpecialization.h"

@class VSequence;

@interface VSequencePreviewView : UIView <VHasManagedDependencies, VStreamCellComponentSpecialization>

+ (Class)classTypeForSequence:(VSequence *)sequence;

+ (VSequencePreviewView *)sequencePreviewViewWithSequence:(VSequence *)sequence;

- (void)setSequence:(VSequence *)sequence;

+ (CGSize)sizeForSequence:(VSequence *)sequence
              withMaxSize:(CGSize)maxSize;

@end
