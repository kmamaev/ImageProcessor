#import "ImageService.h"

// Services
#import "ImageStorageService.h"

// Utils
#import "FileRoutines.h"


static NSString *const _sourceImageName = @"source";
static NSString *const _imageExtension = @"png";
static NSString *const _resultImagesFolderName = @"results";
static NSString *const _resultImagesArrayName = @"resultImageNames";


@interface ImageService ()
@property (nonatomic, readwrite) UIImage *sourceImage;
@property (nonatomic, readwrite) NSURL *sourceImageURL;
@property (nonatomic, readwrite) NSArray<NSURL *> *resultImagesURLs;
@property (nonatomic) NSArray<NSString *> *resultImageNames;
@property (nonatomic) ImageStorageService *imageStorageService;
@end


@implementation ImageService

@synthesize sourceImage = _sourceImage;

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageStorageService = [ImageStorageService sharedInstance];
        NSURL *sourceImageURL = [ImageService sourceImageURL];
        BOOL sourceImageExists = [[NSFileManager defaultManager] fileExistsAtPath:sourceImageURL.path];
        if (sourceImageExists) {
            _sourceImageURL = sourceImageURL;
                [_imageStorageService loadImageWithURL:_sourceImageURL completion:^(UIImage *image) {
                        self.sourceImage = image;
                    }];
        }
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

    if (!self.sourceImageURL) {
        self.sourceImageURL = [ImageService sourceImageURL];
    }
    [self.imageStorageService storeImage:image withURL:self.sourceImageURL];
}

- (NSURL *)addResultImage:(UIImage *)image {
    NSString *fileName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:_imageExtension];
    NSString *imagePath = [[ImageService resultImagesFolderPath] stringByAppendingPathComponent:fileName];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];

    [self.imageStorageService storeImage:image withURL:imageURL];

    NSMutableArray<NSURL *> *resultImagesURLsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImagesURLs))];
    [resultImagesURLsProxy insertObject:imageURL atIndex:0];

    NSMutableArray<NSString *> *resultImagesPathsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImageNames))];
    [resultImagesPathsProxy insertObject:fileName atIndex:0];
    [self.resultImageNames writeToURL:[ImageService resultImagesArrayURL] atomically:YES];

    return imageURL;
}

- (void)deleteResultImageWithURL:(NSURL *)imageURL {
    [self.imageStorageService deleteImageWithURL:imageURL];

    NSMutableArray<NSURL *> *resultImagesURLsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImagesURLs))];
    [resultImagesURLsProxy removeObject:imageURL];

    NSMutableArray<NSString *> *resultImagesPathsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImageNames))];
    [resultImagesPathsProxy removeObject:imageURL.absoluteString.lastPathComponent];
    [self.resultImageNames writeToURL:[ImageService resultImagesArrayURL] atomically:YES];
}

#pragma mark - Auxiliaries

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
