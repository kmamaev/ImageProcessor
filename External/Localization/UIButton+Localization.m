#import "UIButton+Localization.h"
#import "LocalizationRoutines.h"


@implementation UIButton (Localization)

@dynamic localizedNormalTitle, localizedSelectedTitle;

- (void)setLocalizedNormalTitle:(NSString *)localizedNormalTitle {
    [self setTitle:LS(localizedNormalTitle) forState:UIControlStateNormal];
}

- (void)setLocalizedSelectedTitle:(NSString *)localizedSelectedTitle {
    [self setTitle:LS(localizedSelectedTitle) forState:UIControlStateSelected];
}

@end
