#import <UIKit/UIKit.h>

/**
 * Use only with storyboard.
 */
@interface SeparatorView : UIView
@property (strong, nonatomic) IBOutlet UIView *view;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
