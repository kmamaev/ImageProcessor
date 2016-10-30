#import <UIKit/UIKit.h>


@interface ImageStorageService : NSObject

+ (instancetype)sharedInstance;

- (NSOperation *)loadImageWithURL:(NSURL *)imageURL completion:(void (^)(UIImage *image))completion;

/**
 * Stores the specified image on disk asynchronously
 */
- (void)storeImage:(UIImage *)image withURL:(NSURL *)imageURL;

- (void)deleteImageWithURL:(NSURL *)imageURL;

@end
