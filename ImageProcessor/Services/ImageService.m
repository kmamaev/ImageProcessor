#import "ImageService.h"

// Utils
#import "FileRoutines.h"


static NSString *const _sourceImageName = @"source";
static NSString *const _imageExtension = @"png";
static NSString *const _resultImagesFolderName = @"results";
static NSString *const _resultImagesArrayName = @"resultImageNames";


@interface ImageService ()
@property (nonatomic, readwrite) UIImage *sourceImage;
@property (nonatomic, readwrite) NSArray<NSURL *> *resultImagesURLs;
@property (nonatomic) NSArray<NSString *> *resultImageNames;
@end


@implementation ImageService

@synthesize sourceImage = _sourceImage;

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        NSData *sourceImageData = [NSData dataWithContentsOfURL:[ImageService sourceImageURL]];
        _sourceImage = [UIImage imageWithData:sourceImageData];
        _resultImageNames = [NSArray arrayWithContentsOfURL:[ImageService resultImagesArrayURL]];
        if (!_resultImageNames) {
            _resultImageNames = [NSArray array];
        }
        NSMutableArray *resultImagesURLs = [NSMutableArray array];
        for (NSString *resultImageName in _resultImageNames) {
            NSString *resultImagePath = [[ImageService resultImagesFolderPath] stringByAppendingPathComponent:resultImageName];
            [resultImagesURLs addObject:[NSURL fileURLWithPath:resultImagePath]];
        }
        _resultImagesURLs = resultImagesURLs;
    }
    return self;
}

#pragma mark - Public methods

- (void)updateSourceImageWithImage:(UIImage *)image {
    self.sourceImage = image;

    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToURL:[ImageService sourceImageURL] atomically:YES];
}

- (void)addResultImage:(UIImage *)image {
    [ImageService createResultImagesFolderIfNeeded];

    NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:_imageExtension];
    NSString *imagePath = [[ImageService resultImagesFolderPath] stringByAppendingPathComponent:fileName];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];

    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToURL:imageURL atomically:YES];

    NSMutableArray<NSURL *> *resultImagesURLsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImagesURLs))];
    [resultImagesURLsProxy insertObject:imageURL atIndex:0];

    NSMutableArray<NSString *> *resultImagesPathsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImageNames))];
    [resultImagesPathsProxy insertObject:fileName atIndex:0];
    [self.resultImageNames writeToURL:[ImageService resultImagesArrayURL] atomically:YES];
}

- (void)deleteResultImageWithURL:(NSURL *)imageURL {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:imageURL error:&error];
    if (error) {
        NSLog(@"Error: %@.", error.localizedDescription);
        return;
    }

    NSMutableArray<NSURL *> *resultImagesURLsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImagesURLs))];
    [resultImagesURLsProxy removeObject:imageURL];

    NSMutableArray<NSString *> *resultImagesPathsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImageNames))];
    [resultImagesPathsProxy removeObject:imageURL.absoluteString.lastPathComponent];
    [self.resultImageNames writeToURL:[ImageService resultImagesArrayURL] atomically:YES];
}

#pragma mark - Auxiliaries

+ (void)createResultImagesFolderIfNeeded {
    NSString *resultImagesFolderPath = [self resultImagesFolderPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL resultImagesFolderAlreadyExists = [fileManager fileExistsAtPath:resultImagesFolderPath];
    NSError *error = nil;
    if (!resultImagesFolderAlreadyExists) {
        [fileManager createDirectoryAtPath:resultImagesFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"Error: %@.", error.localizedDescription);
        }
    }
}

+ (NSURL *)sourceImageURL {
    NSString *sourceImagePath = [[documentsPath() stringByAppendingPathComponent:_sourceImageName]
        stringByAppendingPathExtension:_imageExtension];
    return [NSURL fileURLWithPath:sourceImagePath];
}

+ (NSString *)resultImagesFolderPath {
    NSString *resultImagesFolderPath = [documentsPath() stringByAppendingPathComponent:_resultImagesFolderName];
    return resultImagesFolderPath;
}

+ (NSURL *)resultImagesArrayURL {
    NSString *resultImagesArrayPath = [documentsPath() stringByAppendingPathComponent:_resultImagesArrayName];
    return [NSURL fileURLWithPath:resultImagesArrayPath];
}

@end
