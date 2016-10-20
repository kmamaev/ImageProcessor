#import "UISearchBar+Localization.h"
#import "LocalizationRoutines.h"


@implementation UISearchBar (Localization)

@dynamic localizedPlaceholder;

- (void)setLocalizedPlaceholder:(NSString *)localizedPlaceholder {
    [self setPlaceholder:LS(localizedPlaceholder)];
}

@end
