//
//  VContentViewAlertHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VContentViewAlertHelper : NSObject

- (UIAlertController *)alertForConfirmDiscardMediaWithDelete:(void(^)())onDelete cancel:(void(^)())onCancel;

- (UIAlertController *)alertForNextSequenceErrorWithDismiss:(void(^)())onDismiss;

@end
