#import <UIKit/UIKit.h>


@interface ImageService : NSObject

@property (nonatomic, readonly) UIImage *sourceImage; // KVO-compatible
@property (nonatomic, readonly) NSURL *sourceImageURL; // KVO-compatible
@property (nonatomic, readonly) NSArray<NSURL *> *resultImagesURLs; // KVO-compatible

- (void)updateSourceImageWithImage:(UIImage *)image;

- (NSURL *)addResultImage:(UIImage *)image;

- (void)deleteResultImageWithURL:(NSURL *)imageURL;

@end
