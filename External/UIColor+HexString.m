#import "UIColor+HexString.h"


@implementation UIColor (HexString)

+ (UIColor *)colorWithHexValue:(unsigned int)hexValue {
    return [self colorWithHexValue:hexValue andAlpha:1];
}

+ (UIColor *)colorWithHexValue:(unsigned int)hexValue andAlpha:(CGFloat)alpha {
    return [UIColor
        colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16))/255.0f
        green:((CGFloat)((hexValue & 0xFF00) >> 8))/255.0f
        blue:((CGFloat)(hexValue & 0xFF))/255.0f
        alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [self colorWithHexString:hexString andAlpha:1];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha {
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
    
    unsigned int hexValue;
    
    if ([[NSScanner scannerWithString:hexString] scanHexInt:&hexValue]) {
        return [self colorWithHexValue:hexValue andAlpha:alpha];
    }
    // Invalid hex string.
    else {
        return [self blackColor];
    }
}

- (UIColor *)colorWithSVMul:(CGFloat)svMul {
    CGFloat h, s, v;
    
    [self getHue:&h saturation:&s brightness:&v alpha:nil];

    v *= svMul;
    s /= svMul;

    return [UIColor colorWithHue:h saturation:s brightness:v alpha:1];
}

- (UIColor *)colorWithVMul:(CGFloat)vMul {
    CGFloat h, s, v;
    
    [self getHue:&h saturation:&s brightness:&v alpha:nil];

    v *= vMul;

    return [UIColor colorWithHue:h saturation:s brightness:v alpha:1];
}

- (NSString *)hexValue {
    CGFloat r, g, b;
    
    [self getRed:&r green:&g blue:&b alpha:nil];

    return [NSString stringWithFormat:@"%02X%02X%02X",
        (unsigned int)(r*0xFF),
        (unsigned int)(g*0xFF),
        (unsigned int)(b*0xFF)];
}

@end
