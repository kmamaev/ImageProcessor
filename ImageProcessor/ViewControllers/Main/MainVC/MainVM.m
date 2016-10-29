#import "MainVM.h"

// ViewModels
#import "ResultImageVM.h"

// Utils
#import "ImageFilterTask.h"
#import "ImageService.h"


@interface MainVM ()
@property (nonatomic, readwrite) ImageService *imageService;
@property (nonatomic, readwrite) NSArray<ResultImageVM *> *resultImageVMs;
@end


@implementation MainVM

#pragma mark - Initialization

- (instancetype)initWithImageService:(ImageService *)imageService {
    self = [super init];
    if (self) {
        _imageService = imageService;
        NSMutableArray *resultImageVMs = [NSMutableArray array];
        for (NSURL *resultImageURL in imageService.resultImagesURLs) {
            ResultImageVM *resultImageVM = [[ResultImageVM alloc] init];
            resultImageVM.resultImageURL = resultImageURL;
            [resultImageVMs addObject:resultImageVM];
        }
        _resultImageVMs = resultImageVMs;
    }
    return self;
}

#pragma mark - Public methods

- (void)addImageFilterTask:(ImageFilterTask *)imageFilterTask {
    ResultImageVM *resultImageVM = [[ResultImageVM alloc] init];
    resultImageVM.imageService = self.imageService;
    resultImageVM.imageFilterTask = imageFilterTask;

    NSMutableArray<ResultImageVM *> *resultImageVMsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImageVMs))];
    [resultImageVMsProxy insertObject:resultImageVM atIndex:0];
}

- (void)updateSourceImageWithImage:(UIImage *)image {
    [self.imageService updateSourceImageWithImage:image];
}

- (void)deleteResultImageVM:(ResultImageVM *)resultImageVM {
    [self.imageService deleteResultImageWithURL:resultImageVM.resultImageURL];

    NSMutableArray<ResultImageVM *> *resultImageVMsProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImageVMs))];
    [resultImageVMsProxy removeObject:resultImageVM];
}

@end
