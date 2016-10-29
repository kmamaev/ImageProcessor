#import <UIKit/UIKit.h>


extern float const MAX_PROGRESS;


@interface ImageFilterTask : NSObject

@property (nonatomic) NSOperation *filteringOperation;
@property (nonatomic) UIImage *filteredImage; // filteredImage has a value when the operation is completed.
@property (nonatomic) float progress; // In percent. Progress is 100 when the operation is completed.

@property (nonatomic) void(^completionBlock)(UIImage *filteredImage);

@end
