#import "MainVC.h"

// Views
#import "ResultImageCell.h"

// Utils
#import "UIColor+ImageProcessorConstants.h"
#import "LocalizationRoutines.h"
#import "UIImage+Filters.h"
#import "NSIndexSet+IndexPaths.h"


static NSString *const _resultImageCellReuseId = @"resultImageCellReuseId";
static void *const _kvoContext = (void *)&_kvoContext;


@interface MainVC () <
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate,
        UITableViewDataSource,
        UITableViewDelegate
    >
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *invisibleViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;
@property (strong, nonatomic) IBOutlet UIImageView *sourceImageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSArray<UIImage *> *resultImages;
@end


@implementation MainVC

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _resultImages = [NSArray array];
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(resultImages)) options:0 context:_kvoContext];
    }
    return self;
}

#pragma mark - Deallocation

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(resultImages)) context:_kvoContext];
}

#pragma mark - ViewController's lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideInvisibleViews];
    [self configureButtons];
    [self configureSourceImageTapRecognizer];
    [self configureTableView];
}

#pragma mark - Configuration

- (void)hideInvisibleViews {
    for (UIView *view in self.invisibleViews) {
        view.backgroundColor = [UIColor clearColor];
    }
}

- (void)configureButtons {
    for (UIButton *button in self.filterButtons) {
        button.backgroundColor = [UIColor buttonColor];
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
}

#pragma mark - Actions

- (void)sourceImageViewTapped:(UITapGestureRecognizer *)sender {
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
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)photoLibraryAction {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

- (void)deleteImage:(UIImage *)image {
    NSMutableArray *resultImagesProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImages))];
    [resultImagesProxy removeObject:image];
}

- (void)useAsSourceImage:(UIImage *)image {
    self.sourceImageView.image = image;
}

- (IBAction)rotateButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image imageRotatedByNintyDegrees];
    [self addResultImage:filteredImage];
}

- (IBAction)monochromeButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image monochromeImage];
    [self addResultImage:filteredImage];
}

- (IBAction)invertColorButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image imageWithInvertedColors];
    [self addResultImage:filteredImage];
}

- (IBAction)mirrorImageButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image imageMirroredHorizontally];
    [self addResultImage:filteredImage];
}

#pragma mark - UIImagePickerControllerDelegate implementation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image
    editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.sourceImageView.image = image;
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultImages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultImageCell *cell = [tableView dequeueReusableCellWithIdentifier:_resultImageCellReuseId
        forIndexPath:indexPath];
    UIImage *image = self.resultImages[indexPath.row];
    [cell configureWithImage:image];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIImage *chosenImage = self.resultImages[indexPath.row];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"General.Cancel") style:UIAlertActionStyleCancel
        handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.SaveImage") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self saveImage:chosenImage];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.UseAsSource") style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self useAsSourceImage:chosenImage];
        }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:LS(@"Main.Action.DeleteImage") style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action) {
            [self deleteImage:chosenImage];
        }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Auxiliaries

- (void)addResultImage:(UIImage *)image {
    NSMutableArray *resultImagesProxy = [self mutableArrayValueForKey:NSStringFromSelector(@selector(resultImages))];
    [resultImagesProxy insertObject:image atIndex:0];
}

#pragma mark - KVO implementation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
    context:(void *)context
{
    if (context == _kvoContext) {
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
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
