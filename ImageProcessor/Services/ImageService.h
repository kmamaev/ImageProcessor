#import <UIKit/UIKit.h>


@interface ImageService : NSObject

- (void)storeAsSourceImage:(UIImage *)image;

- (UIImage *)sourceImage;

@end
