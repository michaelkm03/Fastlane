//
//  VPollSequencePreviewView.h
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"
#import "VFocusable.h"
#import "VPollAnswerReceiver.h"

@interface VPollSequencePreviewView : VSequencePreviewView <VFocusable, VPollAnswerReceiver>

@end
