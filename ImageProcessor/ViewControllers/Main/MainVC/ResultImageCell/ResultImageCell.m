#import "ResultImageCell.h"

// Services
#import "ImageStorageService.h"

// ViewModels
#import "ResultImageVM.h"

// Utils
#import "ImageFilterTask.h"


static void *const _kvoContext = (void *)&_kvoContext;
static NSString *const _resultImageURLKeyPath = @"resultImageVM.resultImageURL";
static NSString *const _resultImageFilterProgressKeyPath = @"resultImageVM.imageFilterTask.progress";


@interface ResultImageCell ()
@property (nonatomic) IBOutlet UIImageView *resultImageView;
@property (nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic) NSOperation *loadImageOperation;
@property (nonatomic) ResultImageVM *resultImageVM;
@end


@implementation ResultImageCell

#pragma mark - Awakening

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.resultImageView.image = nil;

    [self addObserver:self forKeyPath:_resultImageURLKeyPath options:
        NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:_kvoContext];
    [self addObserver:self forKeyPath:_resultImageFilterProgressKeyPath options:
        NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:_kvoContext];
}

#pragma mark - Deallocation

- (void)dealloc {
    [self removeObserver:self forKeyPath:_resultImageURLKeyPath context:_kvoContext];
    [self removeObserver:self forKeyPath:_resultImageFilterProgressKeyPath context:_kvoContext];
}

#pragma mark - Accessors

- (UIImage *)resultImage {
    return self.resultImageView.image;
}

#pragma mark - Public methods

- (void)configureWithResultImageVM:(ResultImageVM *)resultImageVM {
    self.userInteractionEnabled = NO;
    self.resultImageVM = resultImageVM;
}

#pragma mark - Reusing

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.loadImageOperation cancel];
    self.loadImageOperation = nil;

    self.resultImageView.image = nil;
}

#pragma mark - KVO implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
    context:(void *)context
{
    if (context == _kvoContext) {
        if ([keyPath isEqualToString:_resultImageURLKeyPath]) {
            [self handleChangeForResultImageURL:change];
        }
        else if ([keyPath isEqualToString:_resultImageFilterProgressKeyPath]) {
            [self handleChangeForResultImageFilterProgress:change];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)handleChangeForResultImageURL:(NSDictionary *)change {
    if (!self.resultImageVM.resultImageURL) {
        return;
    }
    ImageStorageService *imageStorageService = [ImageStorageService sharedInstance];

    typeof(self) __weak wSelf = self;
    self.loadImageOperation = [imageStorageService loadImageWithURL:self.resultImageVM.resultImageURL
        completion:^(UIImage *image) {
            typeof(wSelf) __strong sSelf = wSelf;
            sSelf.resultImageView.image = image;
            sSelf.userInteractionEnabled = YES;
        }];
}

- (void)handleChangeForResultImageFilterProgress:(NSDictionary *)change {
    self.progressView.progress = self.resultImageVM.imageFilterTask.progress / 100;
    [self updateProgressViewVisibility];
}

#pragma mark - Auxiliaries

- (void)updateProgressViewVisibility {
    BOOL hasImageFilterTask = self.resultImageVM.imageFilterTask != nil;
    BOOL progressIsNotCompleted = self.resultImageVM.imageFilterTask.progress < MAX_PROGRESS;
    BOOL needShowProgress = hasImageFilterTask && progressIsNotCompleted;
    self.progressView.hidden = !needShowProgress;
}

@end
