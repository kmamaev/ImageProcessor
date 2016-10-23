#import "FileRoutines.h"


NSString *documentsPath() {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = path.firstObject;
    return documentsPath;
}
