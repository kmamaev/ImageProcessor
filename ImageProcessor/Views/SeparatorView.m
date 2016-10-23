#import "SeparatorView.h"

// Utils
#import "UIColor+HexString.h"
#import "UIColor+ImageProcessorConstants.h"


@interface SeparatorView ()
@property (nonatomic) IBOutletCollection(UIView) NSArray *boundViews;
@property (nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *boundHeights;
@end


@implementation SeparatorView

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.view];
        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0
            metrics:nil views:@{@"view":self.view}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0
            metrics:nil views:@{@"view":self.view}]];
    }
    return self;
}

#pragma mark - Configuration

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.view.backgroundColor = [UIColor colorWithHexValue:0xEFEFF4];
    [self configureBoundsColors];
    [self configureBoundsHeights];
}

- (void)configureBoundsColors {
    for (UIView *view in self.boundViews) {
        view.backgroundColor = [UIColor separatorColor];
    }
}

- (void)configureBoundsHeights {
    for (NSLayoutConstraint *heightConstraint in self.boundHeights) {
        heightConstraint.constant = 1./[UIScreen mainScreen].scale;
    }
}

@end
