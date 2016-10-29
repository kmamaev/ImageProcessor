#import <UIKit/UIKit.h>

@class ResultImageVM;


@interface ResultImageCell : UITableViewCell

@property (nonatomic, readonly) UIImage *resultImage;

- (void)configureWithResultImageVM:(ResultImageVM *)resultImageVM;

@end
