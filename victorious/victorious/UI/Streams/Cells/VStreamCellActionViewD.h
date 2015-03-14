//
//  VStreamCellActionViewD.h
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCellActionView.h"

@interface VStreamCellActionViewD : VStreamCellActionView

- (void)updateCommentsCount:(NSNumber *)commentsCount;

- (void)addCommentsButton;

@property (nonatomic, strong) UIColor *buttonBackgroundColor;

@end
