#import <UIKit/UIKit.h>


@interface UIImage (Filters)

- (UIImage *)imageRotatedByNinetyDegrees;

- (UIImage *)imageWithInvertedColors;

- (UIImage *)imageMirroredHorizontally;

- (UIImage *)monochromeImage;

/**
 * Mirror left half of the image to it's right half.
 * @return The image from two the same halves but right half is a mirrored reflections of the left half.
 */
- (UIImage *)imageWithMirroredRightPart;

@end
