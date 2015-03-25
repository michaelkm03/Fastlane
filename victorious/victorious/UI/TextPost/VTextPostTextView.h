//
//  VTextPostTextView.h
//  victorious
//
//  Created by Patrick Lynch on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTextPostTextView : UITextView

@property (nonatomic, strong) NSArray *backgroundFrames;
@property (nonatomic, strong) UIColor *backgroundFrameColor;

- (CGRect)boundingRectForCharacterRange:(NSRange)range;

@end
