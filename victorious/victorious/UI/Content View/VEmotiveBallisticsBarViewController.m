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

#import "UIView+VFrameManipulation.h"

@interface VEmotiveBallisticsBarViewController ()

@property (weak, nonatomic) IBOutlet UILabel* positiveEmotiveLabel;
@property (weak, nonatomic) IBOutlet UILabel* negativeEmotiveLabel;
@property (weak, nonatomic) IBOutlet UIButton* positiveEmotiveButton;
@property (weak, nonatomic) IBOutlet UIButton* negativeEmotiveButton;

@property (weak, nonatomic) IBOutlet UIView* backgroundView;
@property (weak, nonatomic) IBOutlet UIView* shadeView;

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
    
    NSMutableArray* positiveEmotiveAnimations = [[NSMutableArray alloc] initWithCapacity:13];
    NSMutableArray* negativeEmotiveAnimations = [[NSMutableArray alloc] initWithCapacity:13];
    for (int i = 0; i < 17; i++)
    {
        if (i<13)
            [positiveEmotiveAnimations addObject:[UIImage imageNamed:[@"Heart" stringByAppendingString:@(i).stringValue]]];
        
        [negativeEmotiveAnimations addObject:[UIImage imageNamed:[@"Tomato" stringByAppendingString:@(i).stringValue]]];
    }
    
    self.positiveEmotiveButton.imageView.animationImages = positiveEmotiveAnimations;
    self.positiveEmotiveButton.imageView.animationDuration = .25f;
    self.positiveEmotiveButton.imageView.animationRepeatCount = 1;
    
    self.negativeEmotiveButton.imageView.animationImages = negativeEmotiveAnimations;
    self.negativeEmotiveButton.imageView.animationDuration = .25f;
    self.negativeEmotiveButton.imageView.animationRepeatCount = 1;
    
    
}

#pragma mark - Animation
- (void)animateIn
{
    __block CGFloat originalBackgroundX = self.backgroundView.frame.origin.x;
    __block CGFloat originalShadeX = self.shadeView.frame.origin.x;
    
    [self.backgroundView setXOrigin:self.view.frame.size.width];
    [self.shadeView setXOrigin:self.view.frame.size.width];
    
    self.negativeEmotiveButton.alpha = 0;
    self.positiveEmotiveButton.alpha = 0;
    
    self.positiveEmotiveLabel.alpha = 0;
    self.negativeEmotiveLabel.alpha = 0;
    
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.backgroundView setXOrigin:originalBackgroundX];
                         [self.shadeView setXOrigin:originalShadeX];
                     }
                     completion:^(BOOL finished) {
                         [self animateInPartTwo];
                     }];
}

- (void)animateInPartTwo
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         self.positiveEmotiveLabel.alpha = 1;
                         self.negativeEmotiveLabel.alpha = 1;
                         
                         self.negativeEmotiveButton.alpha = 1;
                         self.positiveEmotiveButton.alpha = 1;
                     }];
}

- (void)animateOut
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         self.positiveEmotiveLabel.alpha = 0;
                         self.negativeEmotiveLabel.alpha = 0;
                         
                         self.negativeEmotiveButton.alpha = 0;
                         self.positiveEmotiveButton.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self animateOutPartTwo];
                     }];
}

- (void)animateOutPartTwo
{
    [UIView animateWithDuration:.2f
                     animations:^{
                         [self.backgroundView setXOrigin:self.view.frame.size.width];
                         [self.shadeView setXOrigin:self.view.frame.size.width];
                     }];
}

#pragma mark - Actions
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
    
    
    NSMutableArray* emotiveAnimations = [[NSMutableArray alloc] initWithCapacity:13];
    for (int i = 0; i < 17; i++)
    {
        if (emotive == self.positiveEmotiveButton && i<13)
            [emotiveAnimations addObject:[UIImage imageNamed:[@"Heart" stringByAppendingString:@(i).stringValue]]];
        
        else if (emotive == self.negativeEmotiveButton)
            [emotiveAnimations addObject:[UIImage imageNamed:[@"Tomato" stringByAppendingString:@(i).stringValue]]];
    }
    
    thrownImage.animationImages = emotiveAnimations;
    thrownImage.animationDuration = .25f;
    thrownImage.animationRepeatCount = 1;
    
    thrownImage.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:thrownImage];
    [UIView animateWithDuration:.3f
                     animations:^
     {
         thrownImage.center = point;
     }
                     completion:^(BOOL finished)
     {
         [thrownImage startAnimating];
         [self performSelector:@selector(removeThrownImage:) withObject:thrownImage afterDelay:thrownImage.animationDuration];
     }];
}

- (void)removeThrownImage:(UIImageView*)thrownImage
{
    thrownImage.alpha = 0;
    [thrownImage removeFromSuperview];
}

- (float)randomFloat
{
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 2) -1;
}


@end
