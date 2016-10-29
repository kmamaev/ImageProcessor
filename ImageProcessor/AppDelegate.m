#import "AppDelegate.h"

// Utils
#import "FileRoutines.h"

// ViewControllers
#import "MainVC.h"

// Services
#import "ImageFilterService.h"
#import "DelayedImageFilterService.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    NSLog(@"Documents path: %@", documentsPath());
#endif

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainVC *mainVC = [mainStoryboard instantiateInitialViewController];
    id<ImageFilterService> imageFilterService = [[DelayedImageFilterService alloc] init];
    mainVC.imageFilterService = imageFilterService;
    self.window.rootViewController = mainVC;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
