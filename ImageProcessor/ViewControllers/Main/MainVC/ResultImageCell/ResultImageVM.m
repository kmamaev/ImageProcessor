#import "ResultImageVM.h"

// Services
#import "ImageService.h"

// Utils
#import "ImageFilterTask.h"


@implementation ResultImageVM

#pragma mark - Accessors

- (void)setImageFilterTask:(ImageFilterTask *)imageFilterTask {
    _imageFilterTask.completionBlock = nil;
    _imageFilterTask = imageFilterTask;

    if (imageFilterTask.filteredImage) {
        [self processWithImage:imageFilterTask.filteredImage];
    }
    else {
        typeof(self) __weak wSelf = self;
        _imageFilterTask.completionBlock = ^(UIImage *filteredImage) {
                typeof(wSelf) __strong sSelf = wSelf;
                [sSelf processWithImage:imageFilterTask.filteredImage];
            };
    }
}

#pragma mark - Auxiliaries

- (void)processWithImage:(UIImage *)image {
    NSURL *resultImageURL = [self.imageService addResultImage:image];
    self.resultImageURL = resultImageURL;
}

@end
