

#import "RJImagePickerManager.h"
#import "AppDelegate.h"

@interface RJImagePickerManager()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic, copy)UploadImage loadImg;
@property(nonatomic, strong)UIViewController *showVC;
@end

@implementation RJImagePickerManager
+ (instancetype)sharedInstance {
  static RJImagePickerManager *manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[RJImagePickerManager alloc] init];
  });
  return manager;
}

- (void)viewController:(UIViewController *)viewController showTitle:(NSString *)title callBack:(UploadImage)callBack {
    if ((!viewController) || (![viewController isKindOfClass:[UIViewController class]])) {
        return;
    }
    self.loadImg = [callBack copy];
    self.showVC = viewController;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选择",@"拍照", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [sheet showInView:KKeyWindow];
    });
  
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
#if TARGET_IPHONE_SIMULATOR
    ShowAutoHideMBProgressHUD(KKeyWindow, @"请在真机测试摄像头功能");
#else
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    picker.sourceType = sourceType;
    [self.showVC presentViewController:picker animated:YES completion:nil];
#endif
    
  } else if(buttonIndex == 0) {
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
      pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      //pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
      pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
      
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = YES;
    [self.showVC presentViewController:pickerImage animated:YES completion:nil];
  }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (self.loadImg) {
            self.loadImg(image);
        }
    } else {
        ShowAutoHideMBProgressHUD(KKeyWindow, @"请选择图片上传");
    }
  
  
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}



@end
