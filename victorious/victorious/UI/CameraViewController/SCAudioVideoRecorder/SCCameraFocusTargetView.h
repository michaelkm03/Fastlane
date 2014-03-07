//
//  XHCameraTagetView.h
//  iyilunba
//

#import <UIKit/UIKit.h>

@interface SCCameraFocusTargetView : UIView

@property (strong, nonatomic) UIImage *outsideFocusTargetImage;
@property (strong, nonatomic) UIImage *insideFocusTargetImage;
@property (assign, nonatomic) float insideFocusTargetImageSizeRatio;

- (void)startTargeting;
- (void)stopTargeting;

@end
