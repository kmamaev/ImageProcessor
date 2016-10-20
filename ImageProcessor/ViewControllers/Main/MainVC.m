#import "MainVC.h"

// Utils
#import "UIColor+ImageProcessorConstants.h"


@interface MainVC ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *invisibleViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;

@property (strong, nonatomic) IBOutlet UIButton *rotateButton;
@property (strong, nonatomic) IBOutlet UIButton *invertColorsButton;
@property (strong, nonatomic) IBOutlet UIButton *mirrorImageButton;
@end


@implementation MainVC

#pragma mark - ViewController's lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideInvisibleViews];
    [self configureButtons];
}

#pragma mark - Configuration

- (void)hideInvisibleViews {
    for (UIView *view in self.invisibleViews) {
        view.backgroundColor = [UIColor clearColor];
    }
}

- (void)configureButtons {
    for (UIButton *button in self.filterButtons) {
        button.backgroundColor = [UIColor buttonColor];
    }
}

@end
