#import "ImageStorageService.h"

// Utils
#import "UIImage+Decompression.h"


@interface ImageStorageService ()
@property (nonatomic) NSOperationQueue *loadImageQueue;
@property (atomic) NSCache<NSURL *, UIImage *> *imageCache;
@end


@implementation ImageStorageService

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadImageQueue = [[NSOperationQueue alloc] init];
        _imageCache = [[NSCache alloc] init];
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
            UIImage *image = [self.imageCache objectForKey:imageURL];
            if (!image) {
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                if (imageData) {
                    image = [[UIImage imageWithData:imageData] decompressedImage];
                    [self.imageCache setObject:image forKey:imageURL];
                }
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
