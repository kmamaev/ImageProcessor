#import <UIKit/UIKit.h>

@class ImageFilterTask;


@protocol ImageFilterService <NSObject>

- (ImageFilterTask *)rotateByNinetyDegreesWithImage:(UIImage *)image;

- (ImageFilterTask *)invertColorsWithImage:(UIImage *)image;

- (ImageFilterTask *)mirrorHorizontallyWithImage:(UIImage *)image;

- (ImageFilterTask *)makeMonochromeColorsWithImage:(UIImage *)image;

/**
 * Mirror left half of the image to it's right half.
 * @return The image from two the same halves but right half is a mirrored reflections of the left half.
 */
- (ImageFilterTask *)mirrorRightPartWithImage:(UIImage *)image;

@end


@interface ImageFilterService : NSObject <ImageFilterService>
@end
