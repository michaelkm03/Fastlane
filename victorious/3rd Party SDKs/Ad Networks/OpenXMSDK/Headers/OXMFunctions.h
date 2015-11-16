//
//  OXMFunctions.h
//  OpenX_iOS_SDK
//
//  Copyright (c) 2013 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    OXMMRAIDSupportsFeatureSMS = 1,
    OXMMRAIDSupportsFeaturePhone = 1 << 1,
    OXMMRAIDSupportsFeatureCalendar = 1 << 2,
    OXMMRAIDSupportsFeatureSavePicture = 1 << 3,
    OXMMRAIDSupportsFeatureInlineVideo = 1 << 4,    // feature for "inline" video directly in your views; ads may still launch the iOS video player
};
typedef NSUInteger OXMMRAIDSupportsFeatures;

void OXMDisableMRAIDSupportsFeatures(OXMMRAIDSupportsFeatures featuresToDisable);
