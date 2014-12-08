//
//  VInboxBadgeView.h
//  victorious
//
//  Created by David Keegan on 1/2/14.
//  Copyright (c) 2014 Will Long. All rights reserved.
//

/**
 A UILabel subclass designed for displaying
 a badge next to a menu item or in bar
 buttons.
 */
@interface VBadgeLabel : UILabel

/**
 Sets the number displayed
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber;

@end
