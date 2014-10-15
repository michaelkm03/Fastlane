//
//  VFileCache+VoteTypeTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFileCache.h"
#import "VFileCache+VoteType.h"
#import "VAsyncTestHelper.h"
#import "VFileSystemTestHelpers.h"
#import "VDummyModels.h"

@interface VFileCache ( UnitTest)

- (NSString *)keyPathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index;
- (NSString *)keyPathForVoteTypeIcon:(VVoteType *)voteType;
- (NSArray *)keyPathsForVoteTypeSprites:(VVoteType *)voteType;
- (BOOL)validateVoteType:(VVoteType *)voteType;

@end

static NSString * const kTestImageUrl = @"http://mag-corp.com/blog/wp-content/uploads/2014/03/Best-Software-Development-Strategies-3.png";

@interface VFileCache_VoteTypeTests : XCTestCase
{
    VFileCache *_fileCache;
    VAsyncTestHelper *_asyncHelper;
    VVoteType *_voteType;
    
    BOOL _wereFilesCreated;
}

@end

@implementation VFileCache_VoteTypeTests

- (void)setUp
{
    [super setUp];
    
    _wereFilesCreated = NO;
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _fileCache = [[VFileCache alloc] init];
    
    _voteType = [VDummyModels objectWithEntityName:@"VoteType" subclass:[VVoteType class]];
    _voteType.name = @"vote_type_test_name";
    _voteType.icon = kTestImageUrl;
    _voteType.images = @[ kTestImageUrl, kTestImageUrl, kTestImageUrl, kTestImageUrl, kTestImageUrl ];
}

- (void)tearDown
{
    [super tearDown];
    
    if ( _wereFilesCreated )
    {
        NSString *directoryPath = [NSString stringWithFormat:VFileCacheCachedFilepathFormat, _voteType.name];
        XCTAssertEqual( _wereFilesCreated, [VFileSystemTestHelpers deleteCachesDirectory:directoryPath], @"Error deleting contents created by last test." );
    }
    
    _voteType = nil;
    
    _fileCache = nil;
}

- (void)testIconKeyPathConstruction
{
    NSString *iconKeyPath = [_fileCache keyPathForVoteTypeIcon:_voteType];
    NSString *expectedKeyPath = [[NSString stringWithFormat:VFileCacheCachedFilepathFormat, _voteType.name] stringByAppendingPathComponent:VFileCacheCachedIconName];
    XCTAssert( [expectedKeyPath isEqualToString:iconKeyPath] );
}

- (void)testSpriteKeyPathConstruction
{
    for ( NSUInteger i = 0; i < 20; i++ )
    {
        NSString *spriteKeyPath = [_fileCache keyPathForVoteTypeSprite:_voteType atFrameIndex:i];
        NSString *spriteName = [NSString stringWithFormat:VFileCacheCachedSpriteNameFormat, i];
        NSString *expectedKeyPath = [[NSString stringWithFormat:VFileCacheCachedFilepathFormat, _voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssert( [expectedKeyPath isEqualToString:spriteKeyPath] );
    }
}

- (void)testValidateVoteType
{
    XCTAssertFalse( [_fileCache validateVoteType:nil] );
    
    XCTAssertFalse( [_fileCache validateVoteType:(VVoteType *)[NSObject new]] );
    
    _voteType.name = @"";
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    _voteType.name = nil;
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    _voteType.name = @"valid_name";
    _voteType.icon = @"";
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    _voteType.icon = nil;
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    _voteType.name = @"valid_name";
    _voteType.icon = @"valid_icon";
    _voteType.images = @[ kTestImageUrl, kTestImageUrl, @"", kTestImageUrl, kTestImageUrl ];
    XCTAssertFalse( [_fileCache cacheImagesForVoteType:_voteType], @"Cannot have empty URLs in image array.");
}

- (void)testInvalidKeypathInputs
{
    XCTAssertNil( [_fileCache keyPathForVoteTypeIcon:nil] );
    XCTAssertNil( [_fileCache keyPathsForVoteTypeSprites:nil] );
    XCTAssertNil( [_fileCache keyPathForVoteTypeSprite:nil atFrameIndex:0] );
}

- (void)testSpriteKeyPathConstructionArray
{
    NSArray *keyPaths = [_fileCache keyPathsForVoteTypeSprites:_voteType];
    
    [keyPaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger i, BOOL *stop) {
        NSString *spriteName = [NSString stringWithFormat:VFileCacheCachedSpriteNameFormat, i];
        NSString *expectedKeyPath = [[NSString stringWithFormat:VFileCacheCachedFilepathFormat, _voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedKeyPath, keyPath );
    }];
}

- (void)testCacheVoteTypeImages
{
    [_fileCache cacheImagesForVoteType:_voteType];
    
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        
        // Make sure the icon was saved to the right path
        NSString *iconPath = [_fileCache keyPathForVoteTypeIcon:_voteType];
        BOOL iconExists = [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:iconPath];
        
        // Make sure the sprite image swere saved
        __block BOOL spritesExist = YES;
        [((NSArray *)_voteType.images) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *spritePath = [_fileCache keyPathForVoteTypeSprite:_voteType atFrameIndex:idx];
            if ( ![VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:spritePath] )
            {
                spritesExist = NO;
                *stop = YES;
            }
        }];
        
        return iconExists && spritesExist;
    }];
    
    _wereFilesCreated = YES;
}

- (void)testCacheImagesInvalid
{
    XCTAssertFalse( [_fileCache cacheImagesForVoteType:nil] );
}

- (void)testLoadFiles
{
    [self testCacheVoteTypeImages];
    
    UIImage *image = [_fileCache getIconImageForVoteType:_voteType];
    XCTAssertNotNil( image );
}

@end
