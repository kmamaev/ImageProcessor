#import "ResultImageCell.h"


@interface ResultImageCell ()
@property (nonatomic) IBOutlet UIImageView *resultImageView;
@property (nonatomic, readwrite) NSURL *resultImageURL;
@end


@implementation ResultImageCell

#pragma mark - Accessors

- (UIImage *)resultImage {
    return self.resultImageView.image;
}

#pragma mark - Configuration

- (void)configureWithImageURL:(NSURL *)imageURL {
    self.resultImageURL = imageURL;

    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    self.resultImageView.image = image;
}

@end
