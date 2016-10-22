#import "NSIndexSet+IndexPaths.h"


@implementation NSIndexSet (IndexPaths)

- (NSArray *)indexPathsForSection:(NSInteger)section
{
    NSMutableArray __block *indexPaths = [NSMutableArray array];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL __unused *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
        }];
    return indexPaths;
}

@end
