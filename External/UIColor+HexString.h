#import <UIKit/UIKit.h>


@interface UIColor (HexString)
+ (UIColor *)colorWithHexValue:(unsigned int)hexValue;
+ (UIColor *)colorWithHexValue:(unsigned int)hexValue andAlpha:(CGFloat)alpha;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha;
- (UIColor *)colorWithSVMul:(CGFloat)svMul;
- (UIColor *)colorWithVMul:(CGFloat)vMul;
- (NSString *)hexValue;
@end
