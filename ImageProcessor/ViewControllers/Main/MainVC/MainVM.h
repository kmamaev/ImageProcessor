#import <UIKit/UIKit.h>

@class ImageService;
@class ResultImageVM;
@class ImageFilterTask;


@interface MainVM : NSObject
@property (nonatomic, readonly) ImageService *imageService;
@property (nonatomic, readonly) NSArray<ResultImageVM *> *resultImageVMs; // KVO-compatible

- (instancetype)initWithImageService:(ImageService *)imageService;
- (instancetype)init NS_UNAVAILABLE;

- (void)addImageFilterTask:(ImageFilterTask *)imageFilterTask;

- (void)updateSourceImageWithImage:(UIImage *)image;

- (void)deleteResultImageVM:(ResultImageVM *)resultImageVM;

@end