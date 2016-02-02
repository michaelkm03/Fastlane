//
//  VScrollingTextView.h
//  victorious
//
//  Created by Vincent Ho on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VScrollingTextView : UITextView <UITextViewDelegate>

@property (nonatomic) CGFloat maxThreshold;
@property (nonatomic, strong) NSAttributedString *question;

- (void)startScrollWithScrollSpeed:(CGFloat)speed;
- (void)stopScroll;

@end
