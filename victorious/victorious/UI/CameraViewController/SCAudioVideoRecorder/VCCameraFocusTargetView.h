//
//  VCCameraFocusTargetView
//

#import <UIKit/UIKit.h>

@interface VCCameraFocusTargetView : UIView

@property (strong, nonatomic) UIImage *outsideFocusTargetImage;
@property (strong, nonatomic) UIImage *insideFocusTargetImage;
@property (assign, nonatomic) float insideFocusTargetImageSizeRatio;

- (void)startTargeting;
- (void)stopTargeting;

@end
