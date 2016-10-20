#import "UITextField+Localization.h"
#import "LocalizationRoutines.h"


@implementation UITextField (Localization)

@dynamic localizedPlaceholder;

- (void)setLocalizedPlaceholder:(NSString *)localizedPlaceholder {
    [self setPlaceholder:LS(localizedPlaceholder)];
}

@end
