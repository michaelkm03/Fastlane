//
//  VFileCache+VVoteTypeTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VFileSystemTestHelpers.h"
#import "VDummyModels.h"
#import "VVoteType+Fetcher.h"
#import <Nocilla/Nocilla.h>
#import "NSObject+VMethodSwizzling.h"

@interface VFileCache ( UnitTest)

- (NSString *)savePathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index;
- (NSString *)savePathForImage:(NSString *)imageName forVote:(VVoteType *)voteType;
- (NSArray *)savePathsForVoteTypeSprites:(VVoteType *)voteType;
- (BOOL)validateVoteType:(VVoteType *)voteType;

@end

static NSString * const kTestImageUrl = @"http://www.example.com/icon_image.png";

@interface VoteTypeTests : XCTestCase

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) NSArray *voteTypes;
@property (nonatomic, strong) VVoteType *voteType;

@end

@implementation VoteTypeTests

- (void)setUp
{
    [super setUp];
    
    [[LSNocilla sharedInstance] stop];
    [[LSNocilla sharedInstance] start];
    
    self.fileCache = [[VFileCache alloc] init];
    
    NSURL *previewImageFileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"sampleImage" withExtension:@"jpg"];
    NSData *data = [NSData dataWithContentsOfURL:previewImageFileURL];
    
    stubRequest( @"GET", kTestImageUrl ).andReturnRawResponse( data );
    
    self.voteTypes = [VDummyModels createVoteTypes:10];
    [self.voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
    {
        voteType.name = @"vote_type_test_name";
        voteType.iconImage = kTestImageUrl;
        voteType.imageFormat = @"http://www.example.com/image_XXXXX.png";
        voteType.imageCount = @( 10 );
        
        NSString *url = [NSString stringWithFormat:@"http://www.example.com/image_0000%lu.png", (unsigned long)idx];
        stubRequest( @"GET", url ).andReturnRawResponse( data );
        
        NSString *directoryPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.name];
        [VFileSystemTestHelpers deleteCachesDirectory:directoryPath];
    }];
    
    self.voteType = self.voteTypes.firstObject;
}

- (void)tearDown
{
    [super tearDown];
    
    [[LSNocilla sharedInstance] stop];
    
    self.voteTypes = nil;
    self.fileCache = nil;
}

- (void)testSavePathConstructionIcon
{
    NSString *savePath;
    NSString *expectedSavePath;
    
    savePath = [self.fileCache savePathForImage:VVoteTypeIconName forVote:self.voteType];
    expectedSavePath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:VVoteTypeIconName];
    XCTAssertEqualObjects( expectedSavePath, savePath );
}

- (void)testSpriteSavePathConstruction
{
    for ( NSUInteger i = 0; i < 20; i++ )
    {
        NSString *spriteSavePath = [self.fileCache savePathForVoteTypeSprite:self.voteType atFrameIndex:i];
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedSavePath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedSavePath, spriteSavePath );
    }
}

- (void)testSpriteSavePathConstructionArray
{
    NSArray *savePaths = [self.fileCache savePathsForVoteTypeSprites:self.voteType];
    
    [savePaths enumerateObjectsUsingBlock:^(NSString *savePath, NSUInteger i, BOOL *stop) {
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedSavePath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedSavePath, savePath );
    }];
}

- (void)testCacheVoteTypeImages
{
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"icon loaded"];
    __block NSUInteger multiFileCount = 0;
    IMP files = [VFileCache v_swizzleMethod:@selector(cacheFilesAtUrls:withSavePaths:shouldOverwrite:) withBlock:^BOOL (VFileCache *fileCache, NSArray *urls, NSArray *paths, BOOL shouldOverwrite)
                 {
                     if ( ++multiFileCount == self.voteTypes.count )
                     {
                         NSLog( @"%i", multiFileCount );
                         [expectation1 fulfill];
                     }
                     return YES;
    }];
    
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"images loaded"];
    __block NSUInteger singleFileCount = 0;
    IMP file = [VFileCache v_swizzleMethod:@selector(cacheFileAtUrl:withSavePath:shouldOverwrite:) withBlock:^BOOL (VFileCache *fileCache, NSString *url, NSString *path, BOOL shouldOverwrite)
                {
                    if ( ++singleFileCount == self.voteTypes.count )
                    {
                        NSLog( @"%i", singleFileCount );
                        [expectation2 fulfill];
                    }
                    return YES;
                }];
    
    [self.fileCache cacheImagesForVoteTypes:self.voteTypes];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        NSLog( @"waiting..." );
    }];
    
    [VFileCache v_restoreOriginalImplementation:files forMethod:@selector(cacheFilesAtUrls:withSavePaths:shouldOverwrite:)];
    [VFileCache v_restoreOriginalImplementation:file forMethod:@selector(cacheFileAtUrl:withSavePath:shouldOverwrite:)];
}

- (void)testCacheImagesInvalid
{
    XCTAssertNoThrow( [self.fileCache cacheImagesForVoteTypes:@[]] );
    XCTAssertNoThrow( [self.fileCache cacheImagesForVoteTypes:nil] );
    XCTAssertNoThrow( [self.fileCache cacheImagesForVoteTypes:(@[ [NSNull null], [NSNull null] ]) ] );
}

- (void)testFilesDoNotExist
{
    // Dont load files first
    XCTAssertFalse( [self.fileCache isImageCached:VVoteTypeIconName forVoteType:self.voteType] );
    XCTAssertFalse( [self.fileCache areSpriteImagesCachedForVoteType:self.voteType] );
}

@end
