//
//  VContentAlertHelper.h
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VContentAlertHelper : NSObject

/**
 A convenience factory for a load next sequence alert controller.
 */
+ (UIAlertController *)alertForNextSequenceErrorWithDismiss:(nullable void(^)())onDismiss;

@end

NS_ASSUME_NONNULL_END
