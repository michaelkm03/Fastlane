//
//  VHTMLSequncePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHTMLSequncePreviewView.h"

@interface VHTMLSequncePreviewView ()

@property (nonatomic, strong) VSequence *sequence;

@end

@implementation VHTMLSequncePreviewView

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
}

@end
