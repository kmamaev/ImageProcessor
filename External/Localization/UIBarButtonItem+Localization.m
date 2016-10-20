#import "UIBarButtonItem+Localization.h"
#import "LocalizationRoutines.h"


@implementation UIBarButtonItem (Localization)

@dynamic localizedTitle;

- (void)setLocalizedTitle:(NSString *)localizedTitle {
    [self setTitle:LS(localizedTitle)];
}

@end
