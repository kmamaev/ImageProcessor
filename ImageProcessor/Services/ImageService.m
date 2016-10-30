#import "ImageService.h"

// Services
#import "ImageStorageService.h"

// Utils
#import "FileRoutines.h"


static CGFloat const _maxImageResolution = 1080;
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
    self.sourceImage = [[self class] scaleAndRotateImage:image];

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

+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
    CGImageRef imgRef = image.CGImage;

    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = (CGRect){0, 0, width, height};
    if (width > _maxImageResolution || height > _maxImageResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = _maxImageResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = _maxImageResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }

    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }

    UIGraphicsBeginImageContext(bounds.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }

    CGContextConcatCTM(context, transform);

    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}

@end
