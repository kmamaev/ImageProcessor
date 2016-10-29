#import "MainVC.h"

// Services
#import "ImageService.h"
#import "ImageFilterService.h"

// Views
#import "ResultImageCell.h"

// ViewModels
#import "ResultImageVM.h"
#import "MainVM.h"

// Utils
#import "UIColor+ImageProcessorConstants.h"
#import "LocalizationRoutines.h"
#import "NSIndexSet+IndexPaths.h"


static NSString *const _resultImageCellReuseId = @"resultImageCellReuseId";
static void *const _kvoContext = (void *)&_kvoContext;
static NSString *const _resultImageVMsKeyPath = @"mainVM.resultImageVMs";
static NSString *const _sourceImageKeyPath = @"mainVM.imageService.sourceImage";
static NSString *const _sourceImageURLKeyPath = @"mainVM.imageService.sourceImageURL";


@interface MainVC () <
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate,
        UITableViewDataSource,
        UITableViewDelegate
    >
@property (nonatomic) IBOutletCollection(UIView) NSArray *invisibleViews;
@property (nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;
@property (nonatomic) IBOutlet UIImageView *sourceImageView;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIButton *chooseImageButton;
@property (nonatomic) IBOutlet UIButton *rotateButton;
@property (nonatomic) IBOutlet UIButton *monochromeButton;
@property (nonatomic) IBOutlet UIButton *mirrorImageButton;
@property (nonatomic) IBOutlet UIButton *invertColorsButton;
@property (nonatomic) IBOutlet UIButton *mirrorHalvesButton;

@property (nonatomic) MainVM *mainVM;
@end


@implementation MainVC

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _mainVM = [[MainVM alloc] initWithImageService:[[ImageService alloc] init]];
    }
    return self;
}

#pragma mark - Deallocation

- (void)dealloc {
    [self removeObserver:self forKeyPath:_resultImageVMsKeyPath context:_kvoContext];
    [self removeObserver:self forKeyPath:_sourceImageKeyPath context:_kvoContext];
    [self removeObserver:self forKeyPath:_sourceImageURLKeyPath context:_kvoContext];
}

#pragma mark - ViewController's lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureInvisibleViews];
    [self configureTableView];
    [self configureSourceImageTapRecognizer];
    [self configureChooseImageButton];
    [self configureBindings];
}

#pragma mark - Configuration

- (void)configureInvisibleViews {
    for (UIView *view in self.invisibleViews) {
        view.backgroundColor = [UIColor clearColor];
    }
}

- (void)configureSourceImageTapRecognizer {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
        action:@selector(sourceImageViewTapped:)];
    [self.sourceImageView addGestureRecognizer:tapRecognizer];
}

- (void)configureTableView {
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([ResultImageCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:_resultImageCellReuseId];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self configureTableBackgroundView];
}

- (void)configureTableBackgroundView {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor lightGrayColor];
    label.numberOfLines = 0;
    label.text = LS(@"Main.Label.NoResults");
    self.tableView.backgroundView = label;
}

- (void)configureChooseImageButton {
    self.chooseImageButton.backgroundColor = [UIColor buttonColor];
}

- (void)configureBindings {
    [self addObserver:self forKeyPath:_resultImageVMsKeyPath options:0 context:_kvoContext];
    [self addObserver:self forKeyPath:_sourceImageKeyPath options:
        NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:_kvoContext];
    [self addObserver:self forKeyPath:_sourceImageURLKeyPath options:
        NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:_kvoContext];
}

#pragma mark - Actions

- (void)sourceImageViewTapped:(UITapGestureRecognizer *)sender {
    [self chooseImageAction];
}

- (void)chooseImageAction {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"General.Cancel") style:UIAlertActionStyleCancel
        handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.TakePhoto") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self takePhotoAction];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.PhotoLibrary") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self photoLibraryAction];
        }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)takePhotoAction {
    [self openImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
}

- (void)photoLibraryAction {
    [self openImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)saveInGalleryImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (IBAction)filterButtonTapped:(UIButton *)sender {
    ImageFilterTask *filterTask = nil;
    UIImage *imageToFilter = self.mainVM.imageService.sourceImage;
    
    if (sender == self.rotateButton) {
        filterTask = [self.imageFilterService rotateByNinetyDegreesWithImage:imageToFilter];
    }
    else if (sender == self.monochromeButton) {
        filterTask = [self.imageFilterService makeMonochromeColorsWithImage:imageToFilter];
    }
    else if (sender == self.mirrorImageButton) {
        filterTask = [self.imageFilterService mirrorHorizontallyWithImage:imageToFilter];
    }
    else if (sender == self.invertColorsButton) {
        filterTask = [self.imageFilterService invertColorsWithImage:imageToFilter];
    }
    else if (sender == self.mirrorHalvesButton) {
        filterTask = [self.imageFilterService mirrorRightPartWithImage:imageToFilter];
    }

    [self.mainVM addImageFilterTask:filterTask];
}

- (IBAction)chooseImageButtonTapped:(UIButton *)sender {
    [self chooseImageAction];
}

#pragma mark - UIImagePickerControllerDelegate implementation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image
    editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mainVM updateSourceImageWithImage:image];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger resultsCount = self.mainVM.resultImageVMs.count;
    self.tableView.backgroundView.hidden = resultsCount > 0;
    return resultsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultImageCell *cell = [tableView dequeueReusableCellWithIdentifier:_resultImageCellReuseId
        forIndexPath:indexPath];
    ResultImageVM *resultImageVM = self.mainVM.resultImageVMs[indexPath.row];
    [cell configureWithResultImageVM:resultImageVM];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ResultImageVM *chosenResultImageVM = self.mainVM.resultImageVMs[indexPath.row];
    ResultImageCell *resultImageCell = [tableView cellForRowAtIndexPath:indexPath];
    UIImage *chosenImage = resultImageCell.resultImage;

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"General.Cancel") style:UIAlertActionStyleCancel
        handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.SaveImage") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self saveInGalleryImage:chosenImage];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.UseAsSource") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self.mainVM updateSourceImageWithImage:chosenImage];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.DeleteImage") style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action) {
            [self.mainVM deleteResultImageVM:chosenResultImageVM];
        }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Auxiliaries

- (void)updateFilterButtonsStates {
    BOOL needDisableFilters = self.mainVM.imageService.sourceImage == nil;
    for (UIButton *button in self.filterButtons) {
        button.enabled = !needDisableFilters;
        button.backgroundColor = needDisableFilters ? [UIColor grayColor] : [UIColor buttonColor];
    }
}

- (void)updateChooseImageButtonState {
    BOOL needShowChooseImageButton = self.mainVM.imageService.sourceImageURL == nil;
    self.chooseImageButton.hidden = !needShowChooseImageButton;
}

- (void)openImagePickerWithType:(UIImagePickerControllerSourceType)pickerType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = pickerType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - KVO implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
    context:(void *)context
{
    if (context == _kvoContext) {
        if ([keyPath isEqualToString:_resultImageVMsKeyPath]) {
            [self handleChangeForResultImages:change];
        }
        else if ([keyPath isEqualToString:_sourceImageKeyPath]) {
            [self handleChangeForSourceImage:change];
        }
        else if ([keyPath isEqualToString:_sourceImageURLKeyPath]) {
            [self handleChangeForSourceImageURL:change];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)handleChangeForResultImages:(NSDictionary *)change {
    NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
    NSNumber *changeKind = change[NSKeyValueChangeKindKey];
    switch (changeKind.integerValue) {
        case NSKeyValueChangeSetting:
            [self.tableView reloadData];
            break;
        case NSKeyValueChangeInsertion: {
            NSArray *indexPaths = [indexes indexPathsForSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            break;
        }
        case NSKeyValueChangeRemoval: {
            NSArray *indexPaths = [indexes indexPathsForSection:0];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            break;
        }
        case NSKeyValueChangeReplacement: {
            NSArray *indexPaths = [indexes indexPathsForSection:0];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            break;
        }
        default:
            break;
    }
}

- (void)handleChangeForSourceImage:(NSDictionary *__unused)change {
    self.sourceImageView.image = self.mainVM.imageService.sourceImage;
    [self updateFilterButtonsStates];
}

- (void)handleChangeForSourceImageURL:(NSDictionary *__unused)change {
    [self updateChooseImageButtonState];
}

@end
