#import "ImageFilterService.h"

// Services
#import "DelayedImageFilterService.h"

// Utils
#import "ImageFilterTask.h"
#import "UIImage+Filters.h"


typedef NS_ENUM(NSInteger, FilterType) {
    filterTypeUndefined,
    filterTypeRotation,
    filterTypeInvertColors,
    filterTypeMirror,
    filterTypeMonochrome,
    filterTypeMirrorHalves,
};


static NSInteger const _progressStepsCount = 500;


@interface DelayedImageFilterService ()
@property (nonatomic) NSOperationQueue *filterImageQueue;
@end


@implementation DelayedImageFilterService

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _filterImageQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#pragma mark - ImageFilterService implementation

- (ImageFilterTask *)rotateByNinetyDegreesWithImage:(UIImage *)image {
    return [self filteringTaskWithImage:image filterType:filterTypeRotation];
}

- (ImageFilterTask *)invertColorsWithImage:(UIImage *)image {
    return [self filteringTaskWithImage:image filterType:filterTypeInvertColors];
}

- (ImageFilterTask *)mirrorHorizontallyWithImage:(UIImage *)image {
    return [self filteringTaskWithImage:image filterType:filterTypeMirror];
}

- (ImageFilterTask *)makeMonochromeColorsWithImage:(UIImage *)image {
    return [self filteringTaskWithImage:image filterType:filterTypeMonochrome];
}

/**
 * Mirror left half of the image to it's right half.
 * @return The image from two the same halves but right half is a mirrored reflections of the left half.
 */
- (ImageFilterTask *)mirrorRightPartWithImage:(UIImage *)image {
    return [self filteringTaskWithImage:image filterType:filterTypeMirrorHalves];
}

#pragma mark - Auxiliaries

- (ImageFilterTask *)filteringTaskWithImage:(UIImage *)image filterType:(FilterType)filterType {
    ImageFilterTask *filterTask = [[ImageFilterTask alloc] init];

    NSBlockOperation *__block filterImageOperation = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *filteredImage = [[self class] filteredImageWithImage:image filterType:filterType];
            NSInteger secondsDuration = arc4random_uniform(26) + 5;
            for (NSInteger i = 0; i < _progressStepsCount; i++) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        filterTask.progress = i * MAX_PROGRESS / _progressStepsCount;
                    }];
                [NSThread sleepForTimeInterval:(double)secondsDuration/_progressStepsCount];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (!filterImageOperation.isCancelled) {
                        filterTask.filteredImage = filteredImage;
                        filterTask.progress = MAX_PROGRESS;
                        if (filterTask.completionBlock) {
                            filterTask.completionBlock(filteredImage);
                        }
                    }
                }];
        }];

    filterTask.filteringOperation = filterImageOperation;
    [self.filterImageQueue addOperation:filterImageOperation];
    return filterTask;
}

+ (UIImage *)filteredImageWithImage:(UIImage *)image filterType:(FilterType)filterType {
    UIImage *filteredImage = nil;
    switch (filterType) {
        case filterTypeUndefined:break;
        case filterTypeRotation:
            filteredImage = [image imageRotatedByNinetyDegrees];
            break;
        case filterTypeInvertColors:
            filteredImage = [image imageWithInvertedColors];
            break;
        case filterTypeMirror:
            filteredImage = [image imageMirroredHorizontally];
            break;
        case filterTypeMonochrome:
            filteredImage = [image monochromeImage];
            break;
        case filterTypeMirrorHalves:
            filteredImage = [image imageWithMirroredRightPart];
            break;
    }

    return filteredImage;
}

@end
