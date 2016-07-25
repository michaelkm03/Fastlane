//
//  VUserTaggingTextStorage.m
//  victorious
//
//  Created by Josh Hinman on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserTaggingTextStorage.h"
#import "VTag.h"
#import "VTagStringFormatter.h"
#import "VTagDictionary.h"
#import "VDependencyManager.h"
#import "victorious-swift.h"

typedef NS_ENUM(NSInteger, VUserTaggingTextStorageState)
{
    VUserTaggingTextStorageStateInactive,
    VUserTaggingTextStorageStateTriggerStringDetected,
    VUserTaggingTextStorageStateSearchActive
};

static NSString * const kTriggerString = @"@";
static NSString * const kThreeSpaces = @"   ";
static NSString * const VOriginalFont = @"NSOriginalFont";

@interface VUserTaggingTextStorage () <SearchResultsViewControllerDelegate>

@property (nonatomic, strong) NSMutableAttributedString *displayStorage;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSRange searchTermRange; ///< This range includes the trigger character
@property (nonatomic, strong) UserTaggingViewController *userSearchViewController;
@property (nonatomic, strong) VTagDictionary *tagDictionary;
@property (nonatomic, strong) NSString *tagDelimiterString;
@property (nonatomic, assign) NSRange tagSelectionRange;
@property (nonatomic, assign) BOOL needsSelectionUpdate;
@property (nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

@end

@implementation VUserTaggingTextStorage

- (instancetype)init
{
    return [self initWithTextView:nil defaultFont:nil taggingDelegate:nil dependencyManager:nil];
}

- (instancetype)initWithTextView:(UITextView *)textView
                     defaultFont:(UIFont *)defaultFont
                 taggingDelegate:(id<VUserTaggingTextStorageDelegate>)taggingDelegate
               dependencyManager:(VDependencyManager *)dependencyManager
{
    NSParameterAssert(defaultFont != nil);
    NSParameterAssert(dependencyManager != nil);
    
    self = [super init];
    if ( self != nil )
    {
        _taggingDelegate = taggingDelegate;
        _textView = textView;
        _defaultFont = defaultFont;
        _dependencyManager = dependencyManager;
        
        BOOL hasTextView = _textView != nil;
        
        if ( hasTextView )
        {
            [self setupTextView:_textView];
        }
        
        NSString *string = _textView.text;
        if ( !hasTextView || string.length == 0 )
        {
            self.tagDictionary = [[VTagDictionary alloc] init];
        }
    }
    return self;
}

- (void)setTextView:(UITextView *)textView
{
    _textView = textView;
    [self setupTextView:_textView];
}

- (void)setupTextView:(UITextView *)textView
{
    //Add layout manager if needed
    if ( ![self.layoutManagers containsObject:textView.layoutManager] )
    {
        [self addLayoutManager:textView.layoutManager];
    }
    
    NSString *string = textView.text;
    if ( textView != nil && string.length > 0 )
    {
        //Find and replace existing tags in the text view
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
        self.tagDictionary = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:attrString withTagStringAttributes:textView.linkTextAttributes andDefaultStringAttributes:textView.typingAttributes];
        [self replaceCharactersInRange:NSMakeRange(0, self.length) withAttributedString:attrString];
        [textView setSelectedRange:NSMakeRange(attrString.length, 0)];
    }
    
    //Update the typing attributes to include the fixed-height paragraphStyle
    NSMutableDictionary *typingAttributes = [textView.typingAttributes mutableCopy];
    [typingAttributes setValue:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    [textView setTypingAttributes:typingAttributes];
}

- (void)setState:(NSInteger)state
{
    if ( state == _state )
    {
        return;
    }
    
    if (state == VUserTaggingTextStorageStateSearchActive)
    {
        //Search is active, let the delegate know it should show the table
        [self searchWithRange:self.searchTermRange];
        [self.taggingDelegate userTaggingTextStorage:self wantsToShowViewController:self.userSearchViewController];
    }
    else if (state == VUserTaggingTextStorageStateInactive)
    {
        //Search isn't active, let the delegate know we want to dismiss the table
        [self.taggingDelegate userTaggingTextStorage:self wantsToDismissViewController:self.userSearchViewController];
    }
    
    _state = state;
}

- (void)setSearchTermRange:(NSRange)searchTermRange
{
    _searchTermRange = searchTermRange;
    if (self.state == VUserTaggingTextStorageStateSearchActive)
    {
        //Search term has changed, send it to the search table
        [self searchWithRange:searchTermRange];
    }
}

- (void)searchWithRange:(NSRange)range
{
    NSUInteger triggerStringLength = kTriggerString.length;
    
    //If range is <= triggerCharacterLength, the range is looking at a blank or only "kTriggerCharacter" string and does not need to search
    if ( range.length > triggerStringLength )
    {
        NSString *searchTerm = [[self.displayStorage.string substringWithRange:range] substringFromIndex:triggerStringLength];
        [self.userSearchViewController searchWithTerm:searchTerm];
    }
}

#pragma mark - NSAttributedString primatives

- (NSString *)string
{
    return self.displayStorage.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    if ( location < self.displayStorage.length )
    {
        return [self.displayStorage attributesAtIndex:location effectiveRange:range];
    }
    return nil;
}

#pragma mark - NSMutableAttributedString primatives

- (UITextRange *)textRangeFromRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:start offset:range.length];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    return textRange;
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string
{
    self.needsSelectionUpdate = NO;
    if (self.string.length > 0)
    {
        if (range.location != 0)
        {
            //Adding string
            if (range.length == 0)
            {
                //Check if the string to the left of us has tag formatting
                if ( [self isTagAtIndex:range.location - 1] )
                {
                    self.needsSelectionUpdate = YES;
                    range.length++;
                    if ([[self.string substringWithRange:range] isEqualToString:self.tagDelimiterString])
                    {
                        //Trying to append right before end delimiter string, just move replace range past it
                        range.location++;
                        range.length--;
                    }
                    self.tagSelectionRange = range;
                    //Otherwise trying to append in the middle of a tag, replace the tag with this string (trigger that check by making the length > 0)
                }
            }
            
            NSUInteger subtractor = range.length == 0 ? 1 : 0;
            
            NSString *compareString = [self.string substringWithRange:NSMakeRange(range.location - subtractor, 1)];
            if ( [compareString isEqualToString:self.tagDelimiterString] && range.location + 1 - subtractor < self.string.length && [self isTagAtIndex:range.location + 1 - subtractor] ) //Check if string to left of us is delim string
            {
                //Trying to append right after start delimiter string, just move replace range before it
                range.location--;
                self.needsSelectionUpdate = YES;
                self.tagSelectionRange = range;
            }
        }
        
        if (range.length > 0)
        {
            NSIndexSet *tagRanges = [VTagStringFormatter tagRangesInRange:range ofAttributedString:self withTagDictionary:self.tagDictionary];
            if (tagRanges != nil)
            {
                self.needsSelectionUpdate = YES;
                range = [self updateAndReplaceFoundTagsInRanges:tagRanges foundInRange:range];
                self.tagSelectionRange = NSMakeRange(range.location, 0);
            }
            else if ([[self.string substringWithRange:NSMakeRange(range.location, 1)] isEqualToString:self.tagDelimiterString])
            {
                if (range.length != 1)
                {
                    //First char is delim string, remove delim from selection
                    range.length--;
                    range.location++;
                }
                else
                {
                    //We've only selected a delim string but should delete the whole tag associated with it. Find the tag and delete that range
                    NSRange testRange = NSMakeRange(MAX(0, (NSInteger)range.location - 1), MIN(self.string.length - range.location, range.length));
                    NSIndexSet *tagRanges = [VTagStringFormatter tagRangesInRange:testRange ofAttributedString:self withTagDictionary:self.tagDictionary];
                    self.needsSelectionUpdate = YES;
                    range = [self updateAndReplaceFoundTagsInRanges:tagRanges foundInRange:testRange];
                    self.tagSelectionRange = NSMakeRange(range.location, 0);
                }
            }
            else if ([[self.string substringWithRange:NSMakeRange(range.location + range.length - 1, 1)] isEqualToString:self.tagDelimiterString])
            {
                if (range.length != 1)
                {
                    //Last char is delim string but the tag isn't selected, remove delim from selection
                    range.length--;
                }
            }
        }
    }
    
    [self.displayStorage replaceCharactersInRange:range withString:string];
    [self updateStateForReplacementString:string andReplacementRange:range];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(string.length - range.length)];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    if ( self.needsSelectionUpdate )
    {
        //Trying to update attributes when we are updating the cursor location. When updating cursor location, this function can be called with a range outside the string or a range where the old string was (which would make us set attributes incorrectly)
        return;
    }
    
    NSString *substring = [self.string substringWithRange:range];
    NSMutableDictionary *innerAttrs = [[self.displayStorage attributesAtIndex:range.location effectiveRange:nil] mutableCopy];
    [innerAttrs addEntriesFromDictionary:[self.textView typingAttributes]];
    NSMutableDictionary *updatedAttrs = attrs != nil ? [attrs mutableCopy] : [[NSMutableDictionary alloc] init];
    
    if ( [substring isEqualToString:[VTagStringFormatter delimiterString]] && ![self containsAttributes:attrs atIndex:range.location] )
    {
        //We're trying to adjust the formatting of the delimiter string. This should NEVER be allowed, delimiters should always have their original formatting
        return;
    }
    else if ( [self.tagDictionary tagForKey:substring] != nil )
    {
        //We've encountered a tag, add tag attributes
        [updatedAttrs setObject:[self.textView.linkTextAttributes objectForKey:NSForegroundColorAttributeName] forKey:NSForegroundColorAttributeName];
    }

    //Update font to keep consistent formatting even when supporting emoji / other languages
    if ( [attrs objectForKey:NSFontAttributeName] )
    {
        /*
         The attributes want to specify a new foreground font, which is fine, but we need to add the original font
         to the dictionary so when the next character is added we know what font it should have
         */
        [updatedAttrs setValue:self.defaultFont forKey:VOriginalFont];
    }
    else
    {
        /*
         No font is specified by the system, use the font from the displayStorage (if specified) or the default font
         */
        UIFont *font = [innerAttrs objectForKey:NSFontAttributeName];
        font = font == nil ? self.defaultFont : font;
        [updatedAttrs setValue:font forKey:NSFontAttributeName];
    }
    
    [updatedAttrs setValue:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    [self.displayStorage setAttributes:updatedAttrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (BOOL)isTagAtIndex:(NSUInteger)index
{
    if ( self.tagDictionary.count == 0 )
    {
        return NO;
    }
    return [self containsAttributes:[[[self.tagDictionary tags] firstObject] tagStringAttributes] atIndex:index];
}

//Checks that all provided attributes are present in our attributed string at the provided index
- (BOOL)containsAttributes:(NSDictionary *)attributes atIndex:(NSUInteger)index
{
    if ( index >= self.displayStorage.length )
    {
        return NO;
    }
    
    NSDictionary *strAttrs = [self attributesAtIndex:index effectiveRange:nil];
    for (NSString *key in attributes)
    {
        if ( ![[strAttrs objectForKey:key] isEqual:[attributes objectForKey:key]] )
        {
            return NO;
        }
    }
    return YES;
}

//Adjust selection range here to avoid index out of bounds exceptions
- (void)endEditing
{
    [super endEditing];
    if ( self.needsSelectionUpdate )
    {
        self.textView.selectedRange = self.tagSelectionRange;
        
        /*
         We've just updated the cursor location because of tag interaction
         All prior undo actions will be trying to edit the wrong section of our attributedString, remove them to prevent crashes
         */
        [self.textView.undoManager removeAllActions];
    }
    else if ( self.textView.selectedRange.location > self.displayStorage.length )
    {
        self.textView.selectedRange = NSMakeRange(self.displayStorage.length, 0);
    }
}

//Update search state
- (void)updateStateForReplacementString:(NSString *)string andReplacementRange:(NSRange)range
{
    if ( self.disableSearching )
    {
        self.state = VUserTaggingTextStorageStateInactive;
        return;
    }
    
    switch (self.state)
    {
        case VUserTaggingTextStorageStateInactive:
        {
            if ( [string isEqualToString:kTriggerString] )
            {
                self.state = VUserTaggingTextStorageStateTriggerStringDetected;
                self.searchTermRange = NSMakeRange(range.location, kTriggerString.length);
            }
            break;
        }
        case VUserTaggingTextStorageStateTriggerStringDetected:
        {
            if ( string.length != 1 || ![[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:0]] )
            {
                self.state = VUserTaggingTextStorageStateInactive;
                break;
            }
            // fall-through on purpose!
        }
        case VUserTaggingTextStorageStateSearchActive:
        {
            if ( !NSLocationInRange(range.location, NSMakeRange(self.searchTermRange.location + 1, self.searchTermRange.length + 1)) ) // Check to see if the insertion point changed. We consider that a cancellation of search.
            {
                self.state = VUserTaggingTextStorageStateInactive;
            }
            else
            {
                self.searchTermRange = NSMakeRange(self.searchTermRange.location, self.searchTermRange.length + string.length - range.length);
                
                if ( self.searchTermRange.length >= 3 )
                {
                    NSRange rangeOfLastThreeCharacters = NSMakeRange(self.searchTermRange.location + self.searchTermRange.length - 3, 3);
                    NSString *lastThreeCharacters = [self.string substringWithRange:rangeOfLastThreeCharacters];
                    
                    if ( [lastThreeCharacters isEqualToString:kThreeSpaces] )
                    {
                        self.state = VUserTaggingTextStorageStateInactive;
                        break;
                    }
                }
                self.state = VUserTaggingTextStorageStateSearchActive;
            }
            break;
        }
            
        default:
            break;
    }
}

//Remove all found tags and return the range encompassing the full range of the removed text
- (NSRange)updateAndReplaceFoundTagsInRanges:(NSIndexSet *)tagRanges foundInRange:(NSRange)range
{
    if (tagRanges != nil)
    {
        [tagRanges enumerateRangesUsingBlock:^(NSRange r, BOOL *stop)
         {
             
             NSString *key = [self.string substringWithRange:NSMakeRange(r.location + 1, r.length - 2)];
             [self.tagDictionary decrementTagWithKey:key];
             
         }];
        NSRange tagRange = NSMakeRange([tagRanges firstIndex], [tagRanges lastIndex] + 1 - [tagRanges firstIndex]);
        NSUInteger end = MAX(tagRange.location + tagRange.length, range.location + range.length);
        NSUInteger start = MIN(range.location, tagRange.location);
        range = NSMakeRange(start, end - start);
    }
    return range;
}

//Create a database-formatted version of our current attributed string
- (NSString *)databaseFormattedString
{
    return self.textView == nil ? nil : [VTagStringFormatter databaseFormattedStringFromAttributedString:self withTags:[self.tagDictionary tags]];
}

//Convenience wrapper for the VTagStringFormatter delimiter string
- (NSString *)tagDelimiterString
{
    if ( _tagDelimiterString != nil )
    {
        return _tagDelimiterString;
    }
    
    _tagDelimiterString = [VTagStringFormatter delimiterString];
    return _tagDelimiterString;
}

- (UserTaggingViewController *)userSearchViewController
{
    if (_userSearchViewController != nil)
    {
        return _userSearchViewController;
    }
    
    _userSearchViewController = [UserTaggingViewController newWithDependencyManager:self.dependencyManager];
    _userSearchViewController.searchResultsDelegate = self;
    return _userSearchViewController;
}

- (NSMutableAttributedString *)displayStorage
{
    if ( _displayStorage != nil )
    {
        return _displayStorage;
    }
    
    _displayStorage = [[NSMutableAttributedString alloc] init];
    return _displayStorage;
}

- (NSMutableParagraphStyle *)paragraphStyle
{
    if ( _paragraphStyle != nil )
    {
        return _paragraphStyle;
    }
    
    _paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    //Setting min and max line height centers different fonts and keeps line heights uniform
    _paragraphStyle.minimumLineHeight = 17.0f;
    _paragraphStyle.maximumLineHeight = 17.0f;
    
    return _paragraphStyle;
}

#pragma mark - SearchResultsViewControllerDelegate

- (void)searchResultsViewControllerDidSelectResult:(VUser *)user
{
    //Insert username into text and adjust location of cursor
    self.state = VUserTaggingTextStorageStateInactive;
    VTag *tag = [VTag tagWithUser:user andTagStringAttributes:self.textView.linkTextAttributes];
    NSMutableAttributedString *attributedString = [VTagStringFormatter delimitedAttributedString:tag.displayString withDelimiterAttributes:self.textView.typingAttributes];
    
    //adjust selection to right after the newly created display-formatted tag string
    NSRange newSelection = NSMakeRange(self.searchTermRange.location + attributedString.string.length, 0);
    
    //Add newly selected tag to tagDictionary
    [self.tagDictionary incrementTag:tag];
    
    [self replaceCharactersInRange:self.searchTermRange withAttributedString:attributedString];
    
    self.textView.selectedRange = newSelection;
}

- (void)searchResultsViewControllerDidSelectCancel
{
    self.state = VUserTaggingTextStorageStateInactive;
}

- (void)dismissButtonWasPressedInTableView:(VInlineSearchTableViewController *)vInlineSearch
{
    self.state = VUserTaggingTextStorageStateInactive;
}

- (void)repliedToUser:(VUser *)user
{
    if (user.displayName != nil)
    {
        self.textView.text = @" "; // add a space after the user_tag
        // Insert username into text and adjust location of cursor
        self.state = VUserTaggingTextStorageStateInactive;
        VTag *tag = [VTag tagWithUser:user andTagStringAttributes:self.textView.linkTextAttributes];
        NSMutableAttributedString *attributedString = [VTagStringFormatter delimitedAttributedString:tag.displayString withDelimiterAttributes:self.textView.typingAttributes];
        
        // Adjust selection to right after the newly created display-formatted tag string
        NSRange newSelection = NSMakeRange(self.searchTermRange.location + attributedString.string.length + 1, 0);
        
        // Add newly selected tag to tagDictionary
        [self.tagDictionary incrementTag:tag];
        
        NSRange range = NSRangeFromString(self.textView.text);
        [self replaceCharactersInRange:range withAttributedString:attributedString];
        
        self.textView.selectedRange = newSelection;
    }
}

@end
