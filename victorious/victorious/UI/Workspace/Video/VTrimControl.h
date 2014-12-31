//
//  VTrimControl.h
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  VTrimControl maintains a UISlider-like UI for selecting a range of content. VTrimContorl maintains a thumbView allowing the user to grab and pan across the full width of the trim control. VTrimControl passes through any touches that do not hit on the thumb's head or body.
 */
@interface VTrimControl : UIControl

@end
