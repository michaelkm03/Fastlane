//
//  VContentViewAlertHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCommentAlertHelper : NSObject

+ (UIAlertController *)alertForConfirmDiscardMediaWithDelete:(nullable void(^)())onDelete
                                                      cancel:(nullable void(^)())onCancel;

+ (UIAlertController *)alertForNextSequenceErrorWithDismiss:(nullable void(^)())onDismiss;

@end

NS_ASSUME_NONNULL_END
