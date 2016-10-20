#import "UINavigationItem+Localization.h"
#import "LocalizationRoutines.h"


@implementation UINavigationItem (Localization)

@dynamic localizedTitle;

- (void)setLocalizedTitle:(NSString *)localizedTitle {
    [self setTitle:LS(localizedTitle)];
}

@end
