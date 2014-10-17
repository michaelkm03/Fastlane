//
//  VActionSheetTransitioningDelegate.h
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VActionSheetViewController;

/**
 *  A transitioning delegate for the actionsheet. Doesn't remove the presenting VC from the view hierarchy so that the action sheet can blur what is "underneath" it. Adds a dimming view and a tap-away button overlapping the presenting VC.
 */
@interface VActionSheetTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

/**
 *  Providse a transitioning and animation transitioning delegate to the actionsheet VC.
 *
 *  @param actionSheetViewController An action sheet VC to present.
 *
 *  @return An instance of action sheet VC.
 */
+ (instancetype)addNewTransitioningDelegateToActionSheetController:(VActionSheetViewController *)actionSheetViewController;

@end
