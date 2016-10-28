#import "ResultImageCell.h"

// Services
#import "ImageStorageService.h"


@interface ResultImageCell ()
@property (nonatomic) IBOutlet UIImageView *resultImageView;
@property (nonatomic, readwrite) NSURL *resultImageURL;
@property (nonatomic) NSOperation *loadImageOperation;
@end


@implementation ResultImageCell

#pragma mark - Awakening

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.resultImageView.image = nil;
}

#pragma mark - Accessors

- (UIImage *)resultImage {
    return self.resultImageView.image;
}

#pragma mark - Configuration

- (void)configureWithImageURL:(NSURL *)imageURL {
    self.resultImageURL = imageURL;

    ImageStorageService *imageStorageService = [ImageStorageService sharedInstance];

    typeof(self) __weak wSelf = self;
    self.loadImageOperation = [imageStorageService loadImageWithURL:imageURL completion:^(UIImage *image) {
            typeof(wSelf) __strong sSelf = wSelf;
            sSelf.resultImageView.image = image;
        }];
}

#pragma mark - Reusing

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.loadImageOperation cancel];
    self.loadImageOperation = nil;
    self.resultImageView.image = nil;
}

@end
