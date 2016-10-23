#import "UIImage+Filters.h"


@implementation UIImage (Filters)

- (UIImage *)imageRotatedByNinetyDegrees {
    CGSize resultSize = (CGSize){self.size.height, self.size.width};
    UIGraphicsBeginImageContext(resultSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, resultSize.width/2, resultSize.height/2);
    CGContextRotateCTM(context, M_PI/2);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect resultRect = (CGRect){-self.size.width/2, -self.size.height/2, self.size.width, self.size.height};
    CGContextDrawImage(context, resultRect, self.CGImage);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (UIImage *)imageWithInvertedColors {
    CGSize size = self.size;
    int width = size.width;
    int height = size.height;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width * height * 4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colorSpace,
        kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);

    for(int y = 0; y < height; y++) {
        unsigned char *linePointer = &memoryPool[y * width * 4];
        for(int x = 0; x < width; x++) {
            int r, g, b; 
            if(linePointer[3]) {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else {
                r = g = b = 0;
            }
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;

            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *resultImage = [UIImage imageWithCGImage:cgImage];

    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);

    return resultImage;
}

- (UIImage *)imageMirroredHorizontally {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, self.size.width, 0);
    CGContextScaleCTM(context, -1.0f, 1.0f);
    
    CGRect resultRect = (CGRect){0, 0, self.size.width, self.size.height};
    CGContextDrawImage(context, resultRect, self.CGImage);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)monochromeImage {
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, self.CGImage);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, nil, kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, self.CGImage);
    CGImageRef mask = CGBitmapContextCreateImage(context);

    UIImage *resultImage = [UIImage imageWithCGImage:CGImageCreateWithMask(cgImage, mask)];
    CGImageRelease(cgImage);
    CGImageRelease(mask);

    return resultImage;
}

- (UIImage *)imageWithMirroredRightPart {
    UIGraphicsBeginImageContext(self.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Draw left part not mirrored
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGRect leftPartRect = (CGRect){0, 0, self.size.width, self.size.height};
    CGContextSaveGState(context);
    CGContextClipToRect(context, (CGRect){0, 0, self.size.width/2, self.size.height});
    CGContextDrawImage(context, leftPartRect, self.CGImage);
    CGContextRestoreGState(context);

    // Draw right part mirrored
    CGContextTranslateCTM(context, self.size.width, 0);
    CGContextScaleCTM(context, -1.0f, 1.0f);
    CGRect rightPartRect = (CGRect){0, 0, self.size.width, self.size.height};
    CGContextClipToRect(context, (CGRect){0, 0, self.size.width/2, self.size.height});
    CGContextDrawImage(context, rightPartRect, self.CGImage);

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}

@end
