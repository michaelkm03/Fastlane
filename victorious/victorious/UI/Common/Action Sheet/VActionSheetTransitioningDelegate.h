//
//  VActionSheetTransitioningDelegate.h
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VActionSheetViewController;

@interface VActionSheetTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

+ (instancetype)addNewTransitioningDelegateToActionSheetController:(VActionSheetViewController *)actionSheetViewController;

@end
