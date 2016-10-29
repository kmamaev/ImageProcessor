#import <Foundation/Foundation.h>

@class ImageFilterTask;
@class ImageService;


@interface ResultImageVM : NSObject
@property (nonatomic) ImageFilterTask *imageFilterTask;
@property (nonatomic) NSURL *resultImageURL;
@property (nonatomic) ImageService *imageService;
@end
