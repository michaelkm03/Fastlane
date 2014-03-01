//
//  VEmotiveBallisticsViewController.m
//  victorious
//
//  Created by Will Long on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEmotiveBallisticsBarViewController.h"

#import "VConstants.h"
#import "VObjectManager.h"
#import "VLoginViewController.h"

@interface VEmotiveBallisticsBarViewController ()

@property (weak, nonatomic) IBOutlet UILabel* positiveEmotiveLabel;
@property (weak, nonatomic) IBOutlet UILabel* negativeEmotiveLabel;
@property (weak, nonatomic) IBOutlet UIButton* positiveEmotiveButton;
@property (weak, nonatomic) IBOutlet UIButton* negativeEmotiveButton;

@end

@implementation VEmotiveBallisticsBarViewController

+ (VEmotiveBallisticsBarViewController *)sharedInstance
{
    static  VEmotiveBallisticsBarViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VEmotiveBallisticsBarViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kEmotiveBallisticsBarStoryboardID];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//Do any additional setup after loading the view.
    UIPanGestureRecognizer *postivePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    // Setting the swipe direction.
    [self.positiveEmotiveButton addGestureRecognizer:postivePanGesture];
    
    UIPanGestureRecognizer *negativePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.negativeEmotiveButton addGestureRecognizer:negativePanGesture];
}

- (IBAction)pressedPostiveEmotive:(id)sender
{
    CGFloat x = self.target.center.x + ([self randomFloat] * self.target.frame.size.width / 4);
    CGFloat y = self.target.center.y + ([self randomFloat] * self.target.frame.size.height / 4);
    
    [self throwEmotive:self.positiveEmotiveButton toPoint:CGPointMake(x, y)];
}

- (IBAction)pressedNegativeEmotive:(id)sender
{
    CGFloat x = self.target.center.x + ([self randomFloat] * self.target.frame.size.width / 4);
    CGFloat y = self.target.center.y + ([self randomFloat] * self.target.frame.size.height / 4);
    
    [self throwEmotive:self.negativeEmotiveButton toPoint:CGPointMake(x, y)];
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //In points / second
        CGPoint lastPosition = [recognizer locationInView:self.target];
        
        lastPosition.x = fminf(lastPosition.x, self.target.center.x + (self.target.frame.size.width / 4));
        lastPosition.x = fmaxf(lastPosition.x, self.target.center.x - (self.target.frame.size.width / 4));
        lastPosition.y = fminf(lastPosition.y, self.target.center.y + (self.target.frame.size.height / 4));
        lastPosition.y = fmaxf(lastPosition.y, self.target.center.y - (self.target.frame.size.height / 4));

        [self throwEmotive:(UIButton*)recognizer.view toPoint:lastPosition];
    }
}

- (void)throwEmotive:(UIButton*)emotive toPoint:(CGPoint)point
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    point = [self.target convertPoint:point toView:self.view];
    __block UIImageView* thrownImage = [[UIImageView alloc] initWithImage:emotive.imageView.image];
    thrownImage.frame = emotive.frame;
    
    [self.view addSubview:thrownImage];
    [UIView animateWithDuration:.3f
                     animations:^
     {
         thrownImage.center = point;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:.2f
                          animations:^
          {
              thrownImage.alpha = 0;
          }
                          completion:^(BOOL finished)
          {
              [thrownImage removeFromSuperview];
          }];
     }];
}

- (float)randomFloat
{
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 2) -1;
}


@end
