//
//  VCollapsingFlowLayout.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCollapsingFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign, readonly) CGFloat dropDownHeaderMiniumHeight;
@property (nonatomic, assign, readonly) CGSize sizeForContentView;
@property (nonatomic, assign, readonly) CGSize sizeForRealTimeComentsView;

@end
