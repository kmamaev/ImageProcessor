#import "AppDelegate.h"
#import "FileRoutines.h"


@interface AppDelegate ()
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    NSLog(@"Documents path: %@", documentsPath());
#endif

    return YES;
}

@end
