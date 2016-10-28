#import "ImageStorageService.h"

// Utils
#import "UIImage+Decompression.h"


@interface ImageStorageService ()
@property (nonatomic) NSOperationQueue *loadImageQueue;
@end


@implementation ImageStorageService

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadImageQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#pragma mark - Shared instance

+ (instancetype)sharedInstance {
    static ImageStorageService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
        });
    return sharedInstance;
}

#pragma mark - Public methods

- (NSOperation *)loadImageWithURL:(NSURL *)imageURL completion:(void (^)(UIImage *image))completion {
    NSBlockOperation *__block loadImageOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = nil;
            if (imageData) {
                image = [[UIImage imageWithData:imageData] decompressedImage];
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (completion && !loadImageOperation.isCancelled) {
                        completion(image);
                    }
                }];
        }];

    [self.loadImageQueue addOperation:loadImageOperation];

    return loadImageOperation;
}

@end
