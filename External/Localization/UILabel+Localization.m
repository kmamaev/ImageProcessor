#import "UILabel+Localization.h"
#import "LocalizationRoutines.h"


@implementation UILabel (Localization)
@dynamic localizedText;

- (void)setLocalizedText:(NSString *)localizedText {
    [self setText:LS(localizedText)];
}

@end
