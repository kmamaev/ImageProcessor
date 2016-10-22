#import "ResultImageCell.h"


@interface ResultImageCell ()
@property (strong, nonatomic) IBOutlet UIImageView *resultImageView;
@end


@implementation ResultImageCell

#pragma mark - Awakening

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Configuration

- (void)configureWithImage:(UIImage *)image {
    self.resultImageView.image = image;
}

@end
