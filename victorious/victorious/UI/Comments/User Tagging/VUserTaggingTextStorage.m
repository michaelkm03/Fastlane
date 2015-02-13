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
#import "VThemeManager.h"
#import "VDependencyManager.h"
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

@property (nonatomic, strong) NSMutableAttributedString *innerStorage;
@property (nonatomic) NSInteger state;
@property (nonatomic) NSRange searchTermRange; ///< This range includes the trigger character
@property (nonatomic) VInlineSearchTableViewController *searchTableViewController;
@property (nonatomic) VTagDictionary *tagDictionary;
@property (nonatomic) NSString *tagDelimiterString;
@property (nonatomic) NSRange selectionRange;
@property (nonatomic) NSRange tagSelectionRange;
@property (nonatomic) BOOL needsSelectionUpdate;

@end

@implementation VUserTaggingTextStorage

- (instancetype)initWithString:(NSString *)str
          andDependencyManager:(VDependencyManager *)dependencyManager
                      textView:(UITextView *)textView
               taggingDelegate:(id<VUserTaggingTextStorageDelegate>)taggingDelegate
{
    self = [super init];
    if ( self != nil )
    {
        _innerStorage = [[NSMutableAttributedString alloc] init];
        _dependencyManager = dependencyManager;
        _taggingDelegate = taggingDelegate;
        _textView = textView;
        BOOL hasTextView = _textView != nil;
        
        //If passed in a textview, add our layout manager to its layout managers
        if ( hasTextView )
        {
            [self addLayoutManager:_textView.layoutManager];
        }
        
        if ( str != nil && str.length > 0 )
        {
            //Add already present string to inner storage
            if ( hasTextView )
            {
                [self setupStringAttributesDictionariesWithAttributes:textView.typingAttributes];
            }
            
            [self replaceCharactersInRange:NSMakeRange(0, 0) withString:str];
            self.tagDictionary = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:self withTagStringAttributes:self.tagStringAttributes andDefaultStringAttributes:self.defaultStringAttributes];
            if ( hasTextView )
            {
                [_textView setSelectedRange:NSMakeRange(str.length, 0)];
            }
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
        [self.searchTableViewController searchFollowingList:[self.innerStorage.string substringWithRange:self.searchTermRange]];
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
        [self.searchTableViewController searchFollowingList:[[self.innerStorage.string substringWithRange:searchTermRange] stringByReplacingOccurrencesOfString:@"@" withString:@""]];
    }
}

#pragma mark - NSAttributedString primatives

- (NSString *)string
{
    return self.innerStorage.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [self.innerStorage attributesAtIndex:location effectiveRange:range];
}

#pragma mark - NSMutableAttributedString primatives

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
                if ( [self containsAttributes:self.tagStringAttributes atIndex:range.location - 1] )
                {
                    self.needsSelectionUpdate = YES;
                    range.length++;
                    if ([[self.string substringWithRange:range] isEqualToString:self.tagDelimiterString])
                    {
                        //Trying to append right before end delimiter string, just move replace range past it
                        range.location++;
                        range.length--;
                    }
                    else
                    {
                        self.tagSelectionRange = range;
                    }
                    //Otherwise trying to append in the middle of a tag, replace the tag with this string (trigger that check by making the length > 0)
                }
            }
            
            NSUInteger subtractor = range.length == 0 ? 1 : 0;
            
            NSString *compareString = [self.string substringWithRange:NSMakeRange(range.location - subtractor, 1)];
            if ( [compareString isEqualToString:self.tagDelimiterString] && range.location + 1 - subtractor < self.string.length && [self containsAttributes:self.tagStringAttributes atIndex:range.location + 1 - subtractor] ) //Check if string to left of us is delim string
            {
                //Trying to append right before end delimiter string, just move replace range before it
                range.location--;
                self.needsSelectionUpdate = YES;
            }
        }
        
        if (range.length > 0)
        {
            NSIndexSet *tagRanges = [VTagStringFormatter tagRangesInRange:range ofAttributedString:self withTagDictionary:self.tagDictionary];
            if (tagRanges != nil)
            {
                self.needsSelectionUpdate = YES;
                self.tagSelectionRange = range;
                range = [self updateAndReplaceFoundTagsInRanges:tagRanges foundInRange:range];
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
    
    [self.innerStorage replaceCharactersInRange:range withString:string];
    
    //Special handling for the newline character, otherwise will be reset to right before newline (instead of after)
    NSUInteger selectionAdditor = [string isEqualToString:@"\n"] ? 1 : 0;
    self.selectionRange = NSMakeRange(range.location + selectionAdditor, 0);
    [self updateStateForReplacementString:string andReplacementRange:range];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(string.length - range.length)];
}

//Checks that all provided attributes are present in our attributed string at the provided index
- (BOOL)containsAttributes:(NSDictionary *)attributes atIndex:(NSUInteger)index
{
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
    if ( self.needsSelectionUpdate || self.textView.selectedRange.location >= _innerStorage.length )
    {
        self.textView.selectedRange = self.selectionRange;
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
                    NSString *lastThreeCharacters = [self.innerStorage.string substringWithRange:rangeOfLastThreeCharacters];
                    
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
    return [VTagStringFormatter databaseFormattedStringFromAttributedString:self withTags:[self.tagDictionary tags]];
}

- (void)setTextView:(UITextView *)textView
{
    _textView = textView;
    [self setupStringAttributesDictionariesWithAttributes:textView.typingAttributes];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    //This accounts for an awful little bug in subclassingn NSTextStorage
    if (range.location + range.length > self.string.length)
    {
        return;
    }
    
    BOOL badTagFormatting = range.location == self.tagSelectionRange.location;
    if ( range.length == 1 && ([[self.string substringWithRange:range] isEqualToString:self.tagDelimiterString] || badTagFormatting) )
    {
        attrs = self.defaultStringAttributes;
        if ( badTagFormatting )
        {
            self.tagSelectionRange = NSMakeRange(NSNotFound, NSNotFound);
        }
    }
    
    //Setup string attributes if not already set here or by another class
    if ( self.defaultStringAttributes == nil && self.tagStringAttributes == nil )
    {
        [self setupStringAttributesDictionariesWithAttributes:attrs];
    }
    
    [self.innerStorage setAttributes:[self attributesForColor:[attrs objectForKey:NSForegroundColorAttributeName]] range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (NSDictionary *)attributesForColor:(UIColor *)color
{
    return [color isEqual:[self.tagStringAttributes objectForKey:NSForegroundColorAttributeName]] ? self.tagStringAttributes : self.defaultStringAttributes;
}

- (void)setupStringAttributesDictionariesWithAttributes:(NSDictionary *)attributes
{
    if ( [attributes objectForKey:NSFontAttributeName] == nil )
    {
        return;
    }
    
    NSMutableDictionary *dsa = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    //Set the text color to black if none is specified
    if ( [dsa objectForKey:NSForegroundColorAttributeName] )
    {
        [dsa setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    }
    
    self.defaultStringAttributes = dsa;
    
    NSMutableDictionary *tsa = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    UIColor *tagColor = [self.dependencyManager colorForKey:[VTagStringFormatter defaultDependencyManagerTagColorKey]];
    if ( tagColor == nil)
    {
        tagColor = [[VThemeManager sharedThemeManager] themedColorForKey:[VTagStringFormatter defaultThemeManagerTagColorKey]];
    }
    [tsa setObject:tagColor forKey:NSForegroundColorAttributeName];
    
    self.tagStringAttributes = tsa;
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

#pragma mark - VInlineSearchTableViewControllerDelegate

- (void)user:(VUser *)user wasSelectedFromTableView:(VInlineSearchTableViewController *)vInlineSearch
{
    //Insert username into text and adjust location of cursor
    self.state = VUserTaggingTextStorageStateInactive;
    VTag *tag = [VTag tagWithUser:user andTagStringAttributes:self.tagStringAttributes];
    NSMutableAttributedString *attributedString = [VTagStringFormatter delimitedAttributedString:tag.displayString withDelimiterAttributes:self.defaultStringAttributes];
    
    //adjust selection to right after the newly created display-formatted tag string
    NSRange newSelection = NSMakeRange(self.searchTermRange.location + attributedString.string.length, 0);
    [self replaceCharactersInRange:self.searchTermRange withAttributedString:attributedString];
    
    self.textView.selectedRange = newSelection;
    
    //Add newly selected tag to tagDictionary
    [self.tagDictionary incrementTag:tag];
}

@end
