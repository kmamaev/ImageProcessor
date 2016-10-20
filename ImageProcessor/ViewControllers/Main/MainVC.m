#import "MainVC.h"


@interface MainVC ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *invisibleViews;
@end


@implementation MainVC

#pragma mark - ViewController's lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideInvisibleViews];
}

#pragma mark - Configuration

- (void)hideInvisibleViews {
    for (UIView *view in self.invisibleViews) {
        view.backgroundColor = [UIColor clearColor];
    }
}

@end
