//
//  VUserTaggingTextStorage.m
//  victorious
//
//  Created by Josh Hinman on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserTaggingTextStorage.h"
#import "VInlineSearchTableViewController.h"
#import "VUser.h"
#import "VTag.h"
#import "VTagStringFormatter.h"
#import "VTagDictionary.h"

typedef NS_ENUM(NSInteger, VUserTaggingTextStorageState)
{
    VUserTaggingTextStorageStateInactive,
    VUserTaggingTextStorageStateTriggerCharacterDetected,
    VUserTaggingTextStorageStateSearchActive
};

static NSString * const kTriggerCharacter = @"@";
static NSString * const kThreeSpaces = @"   ";

@interface VUserTaggingTextStorage () <VInlineSearchTableViewControllerDelegate>

//Using a UITextView to determine proper font for individual characters to support emojis and other languages (tested on korean)
@property (nonatomic, strong) UITextView *innerTextView;
@property (nonatomic, strong) NSMutableAttributedString *displayStorage;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSRange searchTermRange; ///< This range includes the trigger character
@property (nonatomic, strong) VInlineSearchTableViewController *searchTableViewController;
@property (nonatomic, strong) VTagDictionary *tagDictionary;
@property (nonatomic, strong) NSString *tagDelimiterString;
@property (nonatomic, assign) NSRange tagSelectionRange;
@property (nonatomic, assign) BOOL needsSelectionUpdate;

@end

@implementation VUserTaggingTextStorage

- (instancetype)initWithString:(NSString *)str
                      textView:(UITextView *)textView
               taggingDelegate:(id<VUserTaggingTextStorageDelegate>)taggingDelegate
{
    self = [super init];
    if ( self != nil )
    {
        _innerTextView = [[UITextView alloc] init];
        _taggingDelegate = taggingDelegate;
        _textView = textView;
        BOOL hasTextView = _textView != nil;
        
        //If passed in a textview, add our layout manager to its layout managers
        if ( hasTextView )
        {
            [self addLayoutManager:_textView.layoutManager];
            self.innerTextView.font = _textView.font;
        }
        
        if ( str != nil && str.length > 0 && hasTextView)
        {
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
            self.tagDictionary = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:attrString withTagStringAttributes:_textView.linkTextAttributes andDefaultStringAttributes:_textView.typingAttributes];
            [self replaceCharactersInRange:NSMakeRange(0, 0) withAttributedString:attrString];
            [_textView setSelectedRange:NSMakeRange(str.length, 0)];
        }
        else
        {
            self.tagDictionary = [[VTagDictionary alloc] init];
        }
    }
    return self;
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
        [self.searchTableViewController searchFollowingList:[self.innerTextView.text substringWithRange:self.searchTermRange]];
        [self.taggingDelegate userTaggingTextStorage:self wantsToShowViewController:self.searchTableViewController];
    }
    else if (state == VUserTaggingTextStorageStateInactive)
    {
        //Search isn't active, let the delegate know we want to dismiss the table
        [self.taggingDelegate userTaggingTextStorage:self wantsToDismissViewController:self.searchTableViewController];
    }
    
    _state = state;
}

- (void)setSearchTermRange:(NSRange)searchTermRange
{
    _searchTermRange = searchTermRange;
    if (self.state == VUserTaggingTextStorageStateSearchActive)
    {
        //Search term has changed, send it to the search table
        [self.searchTableViewController searchFollowingList:[[self.innerTextView.text substringWithRange:searchTermRange] stringByReplacingOccurrencesOfString:@"@" withString:@""]];
    }
}

#pragma mark - NSAttributedString primatives

- (NSString *)string
{
    return self.displayStorage.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [self.displayStorage attributesAtIndex:location effectiveRange:range];
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
                    //Otherwise trying to append in the middle of a tag, replace the tag with this string (trigger that check by making the length > 0)
                }
            }
            
            NSUInteger subtractor = range.length == 0 ? 1 : 0;
            
            NSString *compareString = [self.string substringWithRange:NSMakeRange(range.location - subtractor, 1)];
            if ( [compareString isEqualToString:self.tagDelimiterString] && range.location + 1 - subtractor < self.string.length && [self isTagAtIndex:range.location + 1 - subtractor] ) //Check if string to left of us is delim string
            {
                //Trying to append right before end delimiter string, just move replace range before it
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
    
    [self.innerTextView replaceRange:[self textRangeFromRange:range inTextView:self.innerTextView] withText:string];
    NSAttributedString *attrString = [self.innerTextView.attributedText attributedSubstringFromRange:NSMakeRange(range.location, string.length)];
    [self.displayStorage replaceCharactersInRange:range withAttributedString:attrString];
    [self updateStateForReplacementString:string andReplacementRange:range];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(string.length - range.length)];
}


- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    if ( range.location + range.length < self.string.length && [self.tagDictionary tagForKey:[self.string substringWithRange:range]] != nil )
    {
        //We've encountered a tag, add tag attributes
        NSMutableDictionary *mutableAttrs = [[self.displayStorage attributesAtIndex:range.location effectiveRange:nil] mutableCopy];
        [mutableAttrs setObject:[self.textView.linkTextAttributes objectForKey:NSForegroundColorAttributeName] forKey:NSForegroundColorAttributeName];
        attrs = mutableAttrs;
    }

    //Update font from internal UITextView
    NSMutableDictionary *updatedAttrs = [attrs mutableCopy];
    NSDictionary *innerAttrs = [[[self.innerTextView attributedText] attributesAtIndex:range.location effectiveRange:nil] dictionaryWithValuesForKeys:@[NSFontAttributeName]];
    [updatedAttrs addEntriesFromDictionary:innerAttrs];    
    
    [self.displayStorage setAttributes:updatedAttrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (BOOL)isTagAtIndex:(NSUInteger)index
{
    return [self containsAttributes:self.textView.linkTextAttributes atIndex:index];
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
    }
    else if ( self.textView.selectedRange.location > self.displayStorage.length )
    {
        self.textView.selectedRange = NSMakeRange(self.displayStorage.length, 0);
    }
}

//Update search state
- (void)updateStateForReplacementString:(NSString *)string andReplacementRange:(NSRange)range
{
    switch (self.state)
    {
        case VUserTaggingTextStorageStateInactive:
        {
            if ( [string isEqualToString:kTriggerCharacter] )
            {
                self.state = VUserTaggingTextStorageStateTriggerCharacterDetected;
                self.searchTermRange = NSMakeRange(range.location, kTriggerCharacter.length);
            }
            break;
        }
        case VUserTaggingTextStorageStateTriggerCharacterDetected:
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
                    NSString *lastThreeCharacters = [self.innerTextView.text substringWithRange:rangeOfLastThreeCharacters];
                    
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

//Lazy searchTableViewController init
- (VInlineSearchTableViewController *)searchTableViewController
{
    if ( _searchTableViewController != nil )
    {
        return _searchTableViewController;
    }
    
    _searchTableViewController = [[VInlineSearchTableViewController alloc] initWithNibName:nil bundle:nil];
    _searchTableViewController.delegate = self;
    return _searchTableViewController;
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

- (void)setTextView:(UITextView *)textView
{
    _textView = textView;
    self.innerTextView.font = textView.font;
}

#pragma mark - VInlineSearchTableViewControllerDelegate

- (void)user:(VUser *)user wasSelectedFromTableView:(VInlineSearchTableViewController *)vInlineSearch
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

@end
