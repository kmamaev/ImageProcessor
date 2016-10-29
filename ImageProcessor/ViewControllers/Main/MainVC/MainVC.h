#import <UIKit/UIKit.h>

@protocol ImageFilterService;


@interface MainVC : UIViewController
@property (nonatomic) id<ImageFilterService> imageFilterService;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end
