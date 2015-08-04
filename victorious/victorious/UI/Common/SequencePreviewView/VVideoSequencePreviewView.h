//
//  VVideoSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VCellFocus.h"
#import "VPreviewViewBackgroundHost.h"

/**
 *  A Sequence preview view for video sequences.
 */
@interface VVideoSequencePreviewView : VSequencePreviewView <VCellFocus, VPreviewViewBackgroundHost>

@end
