#import "ImageStorageService.h"

// Utils
#import "UIImage+Decompression.h"


@interface ImageStorageService ()
@property (nonatomic) NSOperationQueue *storageAccessQueue;
@property (atomic) NSCache<NSURL *, UIImage *> *imageCache;
@end


@implementation ImageStorageService

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _storageAccessQueue = [[NSOperationQueue alloc] init];
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

    [self.storageAccessQueue addOperation:loadImageOperation];

    return loadImageOperation;
}

- (void)storeImage:(UIImage *)image withURL:(NSURL *)imageURL {
    [[self class] createFolderForImageWithURLIfNeeded:imageURL];

    [self.storageAccessQueue addOperationWithBlock:^{
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToURL:imageURL atomically:YES];
        }];
    [self.imageCache setObject:image forKey:imageURL];
}

- (void)deleteImageWithURL:(NSURL *)imageURL {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:imageURL error:&error];
    if (error) {
        NSLog(@"Error: %@.", error.localizedDescription);
        // TODO: handle error
        return;
    }
    [self.imageCache removeObjectForKey:imageURL];
}

#pragma mark - Auxiliaries

+ (void)createFolderForImageWithURLIfNeeded:(NSURL *)imageURL {
    NSURL *folderURL = [imageURL URLByDeletingLastPathComponent];
    NSString *folderPath = folderURL.path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL resultImagesFolderAlreadyExists = [fileManager fileExistsAtPath:folderPath];
    NSError *error = nil;
    if (!resultImagesFolderAlreadyExists) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error: %@.", error.localizedDescription);
        }
    }
}

@end
