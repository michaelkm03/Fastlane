//
//  VTagSensitiveTextView.h
//  victorious
//
//  Created by Sharif Ahmed on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTagSensitiveTextViewDelegate.h"

#warning ADD DOCUMENTATION / TESTS

@interface VTagSensitiveTextView : UITextView

- (void)setupWithDatabaseFormattedText:(NSString *)databaseFormattedText
                         tagAttributes:(NSDictionary *)tagAttributes
                     defaultAttributes:(NSDictionary *)defaultAttributes
                     andTagTapDelegate:(id<VTagSensitiveTextViewDelegate>)tagTapDelegate;

@property (nonatomic, strong) NSDictionary *tagStringAttributes;
@property (nonatomic, weak) id <VTagSensitiveTextViewDelegate> tagTapDelegate;

@end
