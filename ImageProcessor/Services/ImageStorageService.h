#import <UIKit/UIKit.h>


@interface ImageStorageService : NSObject

+ (instancetype)sharedInstance;

- (NSOperation *)loadImageWithURL:(NSURL *)imageURL completion:(void (^)(UIImage *image))completion;

@end
