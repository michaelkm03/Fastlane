//
//  VTextViewWithCorrectIntrinsicContentSize.m
//  victorious
//
//  Created by Josh Hinman on 9/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSystemVersionDetection.h"
#import "VTextViewWithCorrectIntrinsicContentSize.h"

@interface VTextViewWithCorrectIntrinsicContentSize ()

@property (nonatomic) CGSize textSize;

@end

@implementation VTextViewWithCorrectIntrinsicContentSize

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([VSystemVersionDetection majorVersionNumber] > 7 || [VSystemVersionDetection minorVersionNumber] >= 1)
    {
        return;
    }
    
    CGSize calculatedTextSize = CGSizeMake(self.contentSize.width  + self.contentInset.left + self.contentInset.right  + self.textContainerInset.left + self.textContainerInset.right,
                                           self.contentSize.height + self.contentInset.top  + self.contentInset.bottom + self.textContainerInset.top  + self.textContainerInset.bottom);
    if (!CGSizeEqualToSize(calculatedTextSize, self.textSize))
    {
        self.textSize = calculatedTextSize;
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    if ([VSystemVersionDetection majorVersionNumber] > 7 || [VSystemVersionDetection minorVersionNumber] >= 1)
    {
        return [super intrinsicContentSize];
    }

    return self.textSize;
}

@end
