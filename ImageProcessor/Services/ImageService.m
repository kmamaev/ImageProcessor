#import "ImageService.h"

// Utils
#import "FileRoutines.h"


static NSString *const _sourceImageName = @"source.png";


@implementation ImageService

#pragma mark - Public methods

- (void)storeAsSourceImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:[ImageService sourceImagePath] atomically:YES];
}

- (UIImage *)sourceImage {
    
    UIImage *storedSourceImage = [UIImage imageWithContentsOfFile:[ImageService sourceImagePath]];
    return storedSourceImage;
}

#pragma mark - Auxiliaries

+ (NSString *)sourceImagePath {
    NSString *sourceImagePath = [documentsPath() stringByAppendingPathComponent:_sourceImageName];
    return sourceImagePath;
}

@end
