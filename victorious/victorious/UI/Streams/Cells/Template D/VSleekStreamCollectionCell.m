//
//  VSleekStreamCollectionCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCollectionCell.h"
#import <CCHLinkTextView/CCHLinkTextViewDelegate.h>

#import "VSequence+Fetcher.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "VSequencePreviewView.h"
#import "UIView+AutoLayout.h"
#import "NSString+VParseHelp.h"
#import "VSleekActionView.h"
#import "VHashTagTextView.h"
#import "VStreamCellHeader.h"
#import "VCompatibility.h"
#import "VSequenceCountsTextView.h"
#import "VCellSizeCollection.h"
#import "VCellSizingUserInfoKeys.h"
#import "VInStreamCommentCellContents.h"
#import "VInStreamCommentsShowMoreAttributes.h"
#import "VInStreamCommentsController.h"
#import "VActionButtonAnimationController.h"
#import "VListicleView.h"
#import "VStream.h"
#import "UIResponder+VResponderChain.h"
#import "victorious-Swift.h"
#import "VContentFittingPreviewView.h"
#import "victorious-Swift.h"

@import KVOController;

// These values must match the constraint values in interface builder
static const CGFloat kSleekCellHeaderHeight = 50.0f;
static const CGFloat kSleekCellActionViewHeight = 48.0f;
static const CGFloat kCaptionToPreviewVerticalSpacing = 7.0f;
static const CGFloat kCountsTextViewMinHeight = 0.0f;
static const UIEdgeInsets kCaptionMargins = { 0.0f, 50.0f, kCaptionToPreviewVerticalSpacing, 14.0f };
static const NSUInteger kMaxNumberOfInStreamComments = 3;
static const CGFloat kInStreamCommentsTopSpace = 6.0f;
static NSString * const kShouldShowCommentsKey = @"shouldShowComments";

@interface VSleekStreamCollectionCell () <VBackgroundContainer, CCHLinkTextViewDelegate, VSequenceCountsTextViewDelegate, VideoTracking>

@property (nonatomic, readwrite) VSequencePreviewView *previewView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet UIView *previewContainer;
@property (nonatomic, weak) IBOutlet UIView *loadingBackgroundContainer;
@property (nonatomic, weak) IBOutlet VSleekActionView *sleekActionView;
@property (nonatomic, weak) IBOutlet VStreamCellHeader *headerView;
@property (nonatomic, weak) IBOutlet VHashTagTextView *captionTextView;
@property (nonatomic, weak ) IBOutlet NSLayoutConstraint *previewContainerHeightConstraint;
@property (nonatomic, strong ) IBOutlet NSLayoutConstraint *captionZeroingHeightConstraint;
@property (nonatomic, strong) UIView *dimmingContainer;
@property (nonatomic, strong) VActionButtonAnimationController *actionButtonAnimationController;
@property (nonatomic, weak) IBOutlet VSequenceCountsTextView *countsTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captiontoPreviewVerticalSpacing;
@property (nonatomic, strong) VInStreamCommentsController *inStreamCommentsController;
@property (nonatomic, weak) IBOutlet UICollectionView *inStreamCommentsCollectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inStreamCommentsCollectionViewTopConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *inStreamCommentsCollectionViewBottomConstraint;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *inStreamCommentsCollectionViewHeightConstraint;
@property (nonatomic, readwrite) BOOL needsRefresh;
@property (nonatomic, strong) IBOutlet VListicleView *listicleView;
@property (nonatomic, readwrite) VStreamItem *streamItem;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *textViewConstraint;

@end

@implementation VSleekStreamCollectionCell

@synthesize hasRelinquishedPreviewView = _hasRelinquishedPreviewView;

- (void)setSourceScreenName:(NSString *)sourceScreenName
{
    if (self.headerView != nil)
    {
        self.headerView.sourceScreenName = sourceScreenName;
    }
}

- (NSString *)sourceScreenName
{
    return self.headerView.sourceScreenName;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.previewContainer.clipsToBounds = YES;
    self.captionTextView.contentInset = UIEdgeInsetsZero;
    self.captionTextView.textContainer.lineFragmentPadding = 0.0f;
    self.captionTextView.textContainerInset = UIEdgeInsetsZero;
    self.captionTextView.linkDelegate = self;
    self.captionTextView.accessibilityIdentifier = VAutomationIdentifierStreamCellCaption;
    [self setupDimmingContainer];
    
    self.countsTextView.textSelectionDelegate = self;
    self.inStreamCommentsCollectionViewTopConstraint.constant = kInStreamCommentsTopSpace;
    self.captionZeroingHeightConstraint.constant = 0.0f;
    self.actionButtonAnimationController = [[VActionButtonAnimationController alloc] init];

    if ([AgeGate isAnonymousUser])
    {
        [self.sleekActionView removeFromSuperview];
        self.sleekActionView = nil;
    }
}

+ (VCellSizeCollection *)cellLayoutCollection
{
    static VCellSizeCollection *collection;
    if ( collection == nil )
    {
        collection = [[VCellSizeCollection alloc] init];
        [collection addComponentWithConstantSize:CGSizeMake( 0.0f, kSleekCellHeaderHeight)];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
             CGFloat textHeight = 0.0f;
             if ( [self shouldShowCaptionForSequence:sequence withDependencyManager:dependencyManager] )
             {
                 NSDictionary *attributes = [self sequenceDescriptionAttributesWithDependencyManager:dependencyManager];
                 CGFloat textWidth = size.width - kCaptionMargins.left - kCaptionMargins.right;
                 textHeight = VCEIL( [sequence.name frameSizeForWidth:textWidth andAttributes:attributes].height );
                 textHeight += kCaptionMargins.top;
                 
                 // Add space for the text view inset if necessary
                 UIFont *captionFont = attributes[NSFontAttributeName];
                 textHeight += [captionFont v_fontSpecificTextViewInsets].top;
             }
             return CGSizeMake( 0.0f, textHeight );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
            VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
            VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
            return CGSizeMake( 0.0f, [self shouldShowCaptionForSequence:sequence withDependencyManager:dependencyManager] ? kCaptionToPreviewVerticalSpacing : 0.0f );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
             CGFloat previewHeight =  VCEIL( size.width  / [sequence previewAssetAspectRatio] );
             return CGSizeMake( 0.0f, previewHeight );
         }];
        if ( ![AgeGate isAnonymousUser] )
        {
            [collection addComponentWithConstantSize:CGSizeMake( 0.0f, kSleekCellActionViewHeight)];
        }
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
         {
             CGFloat textWidth = size.width - kCaptionMargins.left - kCaptionMargins.right;
             VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
             NSDictionary *attributes = [[self class] sequenceCountsAttributesWithDependencyManager:dependencyManager];
             
             // FIXME: The use of "V" is just to get a good size for *something* in this text field since
             // we can't know what the actual text for the label is in a static method
             return CGSizeMake( 0.0f, MAX( kCountsTextViewMinHeight, VCEIL( [@"V" frameSizeForWidth:textWidth andAttributes:attributes].height ) ) );
         }];
        [collection addComponentWithDynamicSize:^CGSize(CGSize size, NSDictionary *userInfo)
        {
            CGFloat defaultHeight = VCEIL( ( kSleekCellActionViewHeight - VActionButtonHeight ) / 2 );
            
            VDependencyManager *dependencyManager = userInfo[ kCellSizingDependencyManagerKey ];
            if ( ![[dependencyManager numberForKey:kShouldShowCommentsKey] boolValue] )
            {
                return CGSizeMake( 0.0f, defaultHeight );
            }
            
            VSequence *sequence = userInfo[ kCellSizingSequenceKey ];
            NSArray *comments = [self inStreamCommentsArrayForSequence:sequence];
            if ( comments.count == 0 )
            {
                return CGSizeMake( 0.0f, defaultHeight );
            }
            
            BOOL showPreviousCommentsCellEnabled = [self inStreamCommentsShouldDisplayShowMoreCellForSequence:sequence];
            NSArray *commentCellContents = [VInStreamCommentCellContents inStreamCommentsForComments:[userInfo objectForKey:VCellSizingCommentsKey] andDependencyManager:dependencyManager];
            
            CGFloat width = size.width;
            width -= VCEIL( [VSleekActionView outerMarginForBarWidth:width] );
            CGFloat height = [VInStreamCommentsController desiredHeightForCommentCellContents:commentCellContents withMaxWidth:width showMoreAttributes:[VInStreamCommentsShowMoreAttributes newWithDependencyManager:dependencyManager] andShowMoreCommentsCellEnabled:showPreviousCommentsCellEnabled];
            height += kInStreamCommentsTopSpace; //Top space
            height += VCEIL( ( kSleekCellActionViewHeight - VActionButtonHeight ) / 2.0f ); //Bottom space
            return CGSizeMake( 0.0f, height );
        }];
    }
    return collection;
}

+ (BOOL)inStreamCommentsShouldDisplayShowMoreCellForSequence:(VSequence *)sequence
{
    return sequence.commentCount.unsignedIntegerValue > kMaxNumberOfInStreamComments && [self inStreamCommentsArrayForSequence:sequence].count == kMaxNumberOfInStreamComments;
}

#pragma mark - VSequenceCountsTextViewDelegate

- (void)likersTextSelected
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willShowLikersForSequence:fromView:) withSender:self];
    NSAssert( responder != nil, @"We need an object in the responder chain for commenting or showing comments.");
    [responder willShowLikersForSequence:self.sequence fromView:self];
}

- (void)commentsTextSelected
{
    UIResponder<VSequenceActionsDelegate> *responder = [self targetForAction:@selector(willCommentOnSequence:fromView:) withSender:self];
    NSAssert( responder != nil, @"We need an object in the responder chain for showing likers.");
    [responder willCommentOnSequence:self.sequence fromView:self];
}

#pragma mark - VHasManagedDependencies

- (void)setStream:(VStream *)stream
{
    _stream = stream;
    
    [self updateListicle];
}

- (void)updateListicle
{
    // Implementation removed
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if (_dependencyManager == dependencyManager)
    {
        return;
    }
    _dependencyManager = dependencyManager;

    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    if ([self.sleekActionView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.sleekActionView setDependencyManager:dependencyManager];
    }
    if ([self.headerView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.headerView setDependencyManager:dependencyManager];
    }
    if ([self.captionTextView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.captionTextView setDependencyManager:dependencyManager];
    }
    if ([self.listicleView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.listicleView setDependencyManager:dependencyManager];
    }
    
    [self.countsTextView setTextHighlightAttributes:[[self class] sequenceCountsActiveAttributesWithDependencyManager:dependencyManager]];
    [self.countsTextView setTextAttributes:[[self class] sequenceCountsAttributesWithDependencyManager:dependencyManager]];
    self.inStreamCommentsController.showMoreAttributes = [VInStreamCommentsShowMoreAttributes newWithDependencyManager:dependencyManager];
}

+ (NSDictionary *)sequenceCountsActiveAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    return @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
}

+ (NSDictionary *)sequenceCountsAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIFont *font = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    return @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
}

#pragma mark - Property Accessors

- (void)setSequence:(VSequence *)sequence
{
    if (_sequence == sequence)
    {
        return;
    }
    
    [self.KVOController unobserve:_sequence];
    
    _sequence = sequence;
    
    [self.KVOController observe:_sequence
                        keyPath:@"comments"
                        options:NSKeyValueObservingOptionNew
                         action:@selector(commentsUpdated)];
    
    [self.KVOController observe:_sequence
                        keyPath:@"inStreamComments"
                        options:NSKeyValueObservingOptionNew
                         action:@selector(commentsUpdated)];
    
    [self updatePreviewViewForSequence:_sequence];
    self.headerView.sequence = _sequence;
    self.sleekActionView.sequence = _sequence;
    [self updateCaptionViewForSequence:_sequence];
    [self setNeedsUpdateConstraints];
    
    __weak typeof(self) welf = self;
    NSArray *keyPaths = @[ NSStringFromSelector(@selector(hasReposted)),
                           NSStringFromSelector(@selector(commentCount)),
                           NSStringFromSelector(@selector(likeCount)),
                           NSStringFromSelector(@selector(isLikedByMainUser)) ];
    [self.KVOController observe:_sequence
                       keyPaths:keyPaths
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                          block:^(id observer, id object, NSDictionary *change)
     {
         __strong VSleekStreamCollectionCell *strongSelf = welf;
         if ( strongSelf == nil )
         {
             return;
         }
         
         [strongSelf updateCountsTextViewForSequence:_sequence];
         [strongSelf.actionButtonAnimationController setButton:strongSelf.sleekActionView.likeButton
                                                      selected:_sequence.isLikedByMainUser.boolValue];
         [strongSelf.actionButtonAnimationController setButton:strongSelf.sleekActionView.repostButton
                                                      selected:_sequence.hasReposted.boolValue];
     }];
    
    NSArray *inStreamComments = [[[self class] cellLayoutCollection] commentsForCacheKey:[[self class] cacheKeyForSequence:_sequence]];
    [self.inStreamCommentsController setupWithCommentCellContents:[VInStreamCommentCellContents inStreamCommentsForComments:inStreamComments andDependencyManager:self.dependencyManager] withShowMoreCellVisible:[[self class] inStreamCommentsShouldDisplayShowMoreCellForSequence:_sequence]];
}

- (void)updateCountsTextViewForSequence:(VSequence *)sequence
{
    const BOOL canLike = [self.dependencyManager numberForKey:VDependencyManagerLikeButtonEnabledKey].boolValue;
        
    self.countsTextView.hideComments = !sequence.permissions.canComment;
    self.countsTextView.hideLikes = !canLike;
    [self.countsTextView setCommentsCount:sequence.commentCount.integerValue];
    [self.countsTextView setLikesCount:sequence.likeCount.integerValue];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self.dependencyManager setHighlighted:highlighted onHost:self];
}

#pragma mark - Internal Methods

- (void)setupDimmingContainer
{
    self.dimmingContainer = [UIView new];
    self.dimmingContainer.alpha = 0;
    self.dimmingContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewContainer addSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.dimmingContainer];
}

- (void)updateConstraints
{
    // Add new height constraint for preview container to account for aspect ratio of preview asset
    const CGFloat aspectRatio = [self.sequence previewAssetAspectRatio];
    const BOOL needsAspectRatioUpdate = self.previewContainerHeightConstraint.multiplier != 1.0f / aspectRatio;
    if ( needsAspectRatioUpdate )
    {
        [self.previewContainer removeConstraint:self.previewContainerHeightConstraint];
        NSLayoutConstraint *heightToWidth = [NSLayoutConstraint constraintWithItem:self.previewContainer
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.previewContainer
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:(1.0f / aspectRatio)
                                                                          constant:0.0f];
        [self.previewContainer addConstraint:heightToWidth];
        self.previewContainerHeightConstraint = heightToWidth;
    }
    
    BOOL hasCaption = [[self class] shouldShowCaptionForSequence:self.sequence withDependencyManager:self.dependencyManager];
    self.captiontoPreviewVerticalSpacing.constant = hasCaption ? kCaptionToPreviewVerticalSpacing : 0.0f;
    self.captionZeroingHeightConstraint.active = !hasCaption;
    
    BOOL hasComments = [[self class] inStreamCommentsArrayForSequence:self.sequence].count > 0;
    self.inStreamCommentsCollectionViewBottomConstraint.active = hasComments;
    self.inStreamCommentsCollectionViewHeightConstraint.active = !hasComments;
    
    if ( ![AgeGate isAnonymousUser] )
    {
        self.textViewConstraint.constant = self.sleekActionView.leftMargin;
        self.inStreamCommentsController.leftInset = self.sleekActionView.leftMargin;
    }
    else
    {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.countsTextView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.previewContainer 
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:5]];
    }

    [super updateConstraints];
}

- (void)updatePreviewViewForSequence:(VSequence *)sequence
{
    if ( self.hasRelinquishedPreviewView )
    {
        return;
    }
    
    if ([self.previewView canHandleSequence:sequence])
    {
        [self.previewView setSequence:sequence];
        if ( self.previewView.superview == self.previewContainer )
        {
            //The preview view has the right sequence and is already present in our UI
            return;
        }
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VSequencePreviewView sequencePreviewViewWithSequence:sequence];
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    self.previewView.dependencyManager = self.dependencyManager;
    if ( [self.previewView conformsToProtocol:@protocol(VContentFittingPreviewView)] )
    {
        [(VSequencePreviewView <VContentFittingPreviewView> *)self.previewView updateToFitContent:YES];
    }
    [self.previewView setSequence:sequence];
}

- (void)updateCaptionViewForSequence:(VSequence *)sequence
{
    NSAttributedString *captionAttributedString = nil;
    if ( [[self class] shouldShowCaptionForSequence:sequence withDependencyManager:self.dependencyManager] )
    {
        NSDictionary *attributes = [VSleekStreamCollectionCell sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager];
        captionAttributedString = [[NSAttributedString alloc] initWithString:sequence.name
                                                                  attributes:attributes];
        UIFont *captionFont = attributes[NSFontAttributeName];
        self.captionTextView.textContainerInset = [captionFont v_fontSpecificTextViewInsets];
    }
    self.captionTextView.attributedText = captionAttributedString;
}

+ (BOOL)shouldShowCaptionForSequence:(VSequence *)sequence withDependencyManager:(VDependencyManager *)dependencyManager
{
    return sequence.name.length > 0 && ![sequence.itemSubType isEqualToString:VStreamItemSubTypeText] && dependencyManager != nil;
}

- (void)prepareForReuse
{
    self.listicleView.hidden = YES;
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.loadingBackgroundContainer;
}

- (UIView *)backgroundContainerView
{
    return self.contentView;
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *identifier = baseIdentifier == nil ? [[NSString alloc] init] : baseIdentifier;
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        identifier = [VSequencePreviewView reuseIdentifierForSequence:(VSequence *)streamItem
                                                       baseIdentifier:identifier
                                                    dependencyManager:dependencyManager];
    }
    
    return [VSleekActionView reuseIdentifierForStreamItem:streamItem
                                           baseIdentifier:identifier
                                        dependencyManager:dependencyManager];
}

#pragma mark - Class Methods

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if ( dependencyManager != nil )
    {
        UIFont *captionFont = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = [captionFont v_fontSpecificLineSpace];
        
        attributes[ NSFontAttributeName ] = captionFont;
        attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    }
    return [NSDictionary dictionaryWithDictionary:attributes];
}

#pragma mark - Sizing

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager
{
    if (sequence == nil)
    {
        return CGSizeZero;
    }
    
    CGSize base = CGSizeMake( CGRectGetWidth(bounds), 0.0 );
    NSArray *comments = [self inStreamCommentsArrayForSequence:sequence] ?: @[];
    NSDictionary *userInfo = @{ kCellSizingSequenceKey : sequence,
                                VCellSizeCacheKey : [self cacheKeyForSequence:sequence],
                                kCellSizingDependencyManagerKey : dependencyManager,
                                VCellSizingCommentsKey: comments };
    return [[[self class] cellLayoutCollection] totalSizeWithBaseSize:base userInfo:userInfo];
}

#pragma mark - VFocusable

@synthesize focusType = _focusType;

- (void)setFocusType:(VFocusType)focusType
{
    _focusType = focusType;
    if ( self.hasRelinquishedPreviewView )
    {
        return;
    }
    
    if ([self.previewView conformsToProtocol:@protocol(VFocusable)])
    {
        [(id <VFocusable>)self.previewView setFocusType:focusType];
    }
}

- (CGRect)contentArea
{
    return self.previewContainer.frame;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    UIResponder<VSequenceActionsDelegate> *targetForHashTagSelection = [self targetForAction:@selector(hashTag:tappedFromSequence:fromView:)
                                                                                  withSender:self];
    if (targetForHashTagSelection == nil)
    {
        NSAssert(false, @"We need an object in the responder chain for hash tag selection.!");
    }
    [targetForHashTagSelection hashTag:value
                    tappedFromSequence:self.sequence
                              fromView:self];
}

#pragma mark - Autoplay tracking

- (void)trackAutoplayEvent:(VideoTrackingEvent *__nonnull)event
{
    // Set context and continue walking up responder chain
    event.context = self.context;
    event.autoPlay = YES;
    
    id<VideoTracking>responder = [self.nextResponder v_targetConformingToProtocol:@protocol(VideoTracking)];
    if ( responder != nil )
    {
        [responder trackAutoplayEvent:event];
    }
    else
    {
        [event track];
    }
}

- (NSDictionary *__nonnull)additionalInfo
{
    return [self.previewView trackingInfo] ?: @{};
}

#pragma mark - VHighlightContainer

- (UIView *)highlightContainerView
{
    return self.dimmingContainer;
}

- (UIView *)highlightActionView
{
    return self.dimmingContainer;
}

#pragma mark - VStreamCellTracking

- (VSequence *)sequenceToTrack
{
    return self.sequence;
}

- (void)commentsUpdated
{
    self.needsRefresh = YES;
}

- (void)purgeSizeCacheValue
{
    [[[self class] cellLayoutCollection] removeSizeCacheForItemWithCacheKey:[[self class] cacheKeyForSequence:self.sequence]];
    self.needsRefresh = NO;
}

+ (NSString *)cacheKeyForSequence:(VSequence *)sequence
{
    return sequence.remoteId ?: @"";
}

+ (NSArray *)inStreamCommentsArrayForSequence:(VSequence *)sequence
{
    NSArray *recentComments = [[sequence recentComments] array];
    NSArray *comments = [sequence dateSortedComments];
    if ( comments.count > recentComments.count )
    {
        return [comments subarrayWithRange:NSMakeRange(0, MIN(comments.count, kMaxNumberOfInStreamComments))];
    }
    return recentComments;
}

- (VInStreamCommentsController *)inStreamCommentsController
{
    if ( _inStreamCommentsController != nil )
    {
        return _inStreamCommentsController;
    }
    
    if ( [[self.dependencyManager numberForKey:kShouldShowCommentsKey] boolValue] )
    {
        _inStreamCommentsController = [[VInStreamCommentsController alloc] initWithCollectionView:self.inStreamCommentsCollectionView];
    }
    return _inStreamCommentsController;
}

#pragma mark - VContentPreviewViewProvider

- (void)relinquishPreviewView
{
    self.hasRelinquishedPreviewView = YES;
}

- (UIView *)getPreviewView
{
    return self.previewView;
}

- (UIView *)getContainerView
{
    return self.previewView;
}

- (void)restorePreviewView:(VSequencePreviewView *)previewView
{
    self.hasRelinquishedPreviewView = NO;
    self.previewView = previewView;
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    
    if ( !self.hasRelinquishedPreviewView && [self.previewView conformsToProtocol:@protocol(VFocusable)] && self.previewView.focusType != self.focusType )
    {
        self.previewView.focusType = self.focusType;
    }
}

- (void)makeVideoContentHidden:(BOOL)hidden
{
    if ( !self.hasRelinquishedPreviewView && [self.previewView isKindOfClass:[VBaseVideoSequencePreviewView class]] )
    {
        VBaseVideoSequencePreviewView *videoPreviewView = (VBaseVideoSequencePreviewView *)self.previewView;
        if ( hidden )
        {
            //Force to hide
            videoPreviewView.videoPlayer.view.hidden = YES;
        }
        else
        {
            //Allow the preview view to adjust as it's sequence desires
            [videoPreviewView updateStateOfVideoPlayerView];
        }
    }
}

@end
