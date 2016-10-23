#import <UIKit/UIKit.h>


@interface ResultImageCell : UITableViewCell

@property (nonatomic, readonly) NSURL *resultImageURL;
@property (nonatomic, readonly) UIImage *resultImage;

- (void)configureWithImageURL:(NSURL *)imageURL;

@end
