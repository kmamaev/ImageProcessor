#import "FileRoutines.h"


static NSString *docPath = nil;


NSString *documentsPath() {
    if (!docPath) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docPath = path.firstObject;
    }
    return docPath;
}
