#import "MainVC.h"

// Utils
#import "UIColor+ImageProcessorConstants.h"
#import "LocalizationRoutines.h"
#import "UIImage+Filters.h"


@interface MainVC () <
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate
    >
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *invisibleViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *filterButtons;

@property (strong, nonatomic) IBOutlet UIImageView *sourceImageView;
@end


@implementation MainVC

#pragma mark - ViewController's lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hideInvisibleViews];
    [self configureButtons];
    [self configureSourceImageTapRecognizer];
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


- (IBAction)rotateButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image imageRotatedByNintyDegrees];
    self.sourceImageView.image = filteredImage;
}

- (IBAction)monochromeButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image monochromeImage];
    self.sourceImageView.image = filteredImage;
}

- (IBAction)invertColorButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image imageWithInvertedColors];
    self.sourceImageView.image = filteredImage;
}

- (IBAction)mirrorImageButtonTapped:(UIButton *)sender {
    UIImage *filteredImage = [self.sourceImageView.image imageMirroredHorizontally];
    self.sourceImageView.image = filteredImage;
}

#pragma mark - UIImagePickerControllerDelegate implementation

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image
    editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.sourceImageView.image = image;
}

@end
