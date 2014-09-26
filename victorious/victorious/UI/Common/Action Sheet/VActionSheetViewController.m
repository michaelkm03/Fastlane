//
//  VActionSheetViewController.m
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetViewController.h"

// Categories
#import "UIView+MotionEffects.h"
#import "UIView+VShadows.h"

typedef NS_ENUM(NSInteger, VActionSheetTableViewSecion)
{
    VActionSheetTableViewSecionDescription,
    VActionSheetTableViewSecionActions,
    VActionSheetTableViewSecionCount
};

@interface VActionSheetViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *addedItems;
@property (nonatomic, strong) NSArray *actionItems;

@property (weak, nonatomic) IBOutlet UIView *blurringContainer;
@property (weak, nonatomic) IBOutlet UITableView *actionItemsTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *AvatarImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blurringContainerHeightConstraint;

@end

@implementation VActionSheetViewController

#pragma mark - Factory Methods

+ (VActionSheetViewController *)actionSheetViewController
{
    UIStoryboard *ourStoryboard = [UIStoryboard storyboardWithName:@"ActionSheet" bundle:nil];
    return [ourStoryboard instantiateInitialViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIToolbar *blurredView = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.blurringContainer.bounds),
                                                                         CGRectGetHeight(self.blurringContainer.bounds) * 2.0f)];
    blurredView.translucent = YES;
    blurredView.barStyle = UIBarStyleDefault;
    blurredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.blurringContainer insertSubview:blurredView
                                  atIndex:0];
    
    [self.AvatarImageView v_addMotionEffectsWithMagnitude:10.0f];
    self.AvatarImageView.layer.cornerRadius = CGRectGetWidth(self.AvatarImageView.bounds) * 0.5f;
    self.AvatarImageView.layer.masksToBounds = YES;
    
    [self reloadData];
}

#pragma mark - IBActions

- (IBAction)pressedCancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)pressedTapAwayButton:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                     completion:nil];
}

#pragma mark - Public Methods

- (void)addActionItems:(NSArray *)actionItems
{
    self.addedItems = actionItems;
}

- (void)reloadData
{
    NSMutableArray *actionItems = [[NSMutableArray alloc] init];
    [self.addedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if (![obj isKindOfClass:[VActionItem class]])
         {
             NSAssert(false, @"All action items must be of class VActionItem");
         }
         VActionItem *actionItem = (VActionItem *)obj;
         switch (actionItem.type)
         {
             case VActionItemTypeDefault:
                 [actionItems addObject:actionItem];
                 break;
             case VActionItemTypeUser:
                 [self.AvatarImageView setImageWithURL:actionItem.avatarURL
                                      placeholderImage:[UIImage imageNamed:@"profileGenericUser"]];
                 break;
             case VActionItemTypeDescriptionWithHashTags:
                 break;
         }
     }];
    self.actionItems = [NSArray arrayWithArray:actionItems];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return VActionSheetTableViewSecionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case VActionSheetTableViewSecionDescription:
            return 1;
        case VActionSheetTableViewSecionActions:
            return (NSInteger)self.actionItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"default"];
}

@end
