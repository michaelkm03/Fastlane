//
//  VPollSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VFocusable.h"
#import "VPollResultReceiver.h"

// Will note send detail delegate until focusType is VFocusTypeDetail.
@interface VPollSequencePreviewView : VSequencePreviewView <VFocusable, VPollResultReceiver>

@end
