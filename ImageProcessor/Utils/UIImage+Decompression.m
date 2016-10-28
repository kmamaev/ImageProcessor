#import "UIImage+Decompression.h"


@implementation UIImage (Decompression)

- (UIImage *)decompressedImage {
    CGImageRef imageRef = self.CGImage;
    CGSize imageSize = (CGSize){CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)};
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height,
        CGImageGetBitsPerComponent(imageRef), 0, rgbColorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(rgbColorSpace);
    if (!context) {
        return self;
    }

    CGRect imageRect = (CGRect){CGPointZero, imageSize};
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

@end
