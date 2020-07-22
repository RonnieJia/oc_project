

#ifndef RJTools_h
#define RJTools_h

#if defined __cplusplus
extern "C" {
#endif
    

#pragma mark - UIView
extern UIView *RJCreateView(CGRect frame, UIColor *backgroundColor, BOOL clips, CGFloat layerCornerRadius, UIColor *borderColor, CGFloat borderWidth);

extern UIView *RJCreateSimpleView(CGRect frame, UIColor *backgroundColor);

#pragma mark - UILable
extern UILabel *RJCreateLable(CGRect frame, UIFont *font, UIColor *color, NSTextAlignment textAlignment, NSString *text);

extern UILabel *RJCreateDefaultLable(CGRect frame, UIFont *font, UIColor *color, NSString *text);

#pragma mark - UIButton
extern UIButton *RJCreateButton(CGRect frame, UIFont *font, UIColor *textColor, UIColor *backgroundColor, UIImage *backgroundImg, UIImage *image, NSString *title);

extern UIButton *RJCreateTextButton(CGRect frame, UIFont *font, UIColor *textColor, UIImage *backgroundImg, NSString *title);

extern UIButton *RJCreateImageButton(CGRect frame, UIImage *normalImage, UIImage *selectImage);

#pragma mark - UITextField
extern UITextField *RJCreateTextField(CGRect frame, UIFont *font, UIColor *textColor, UIColor *placeholderColor, UIColor *backgroundColor, UIView *left, UIView *right, BOOL secure, NSString *placeholder, NSString *text);

extern UITextField *RJCreateSimpleTextField(CGRect frame, UIFont *font, UIColor *textColor, NSString *placeholder, NSString *text);

#pragma mark - UIImageView
extern UIImageView *RJCreateImageView(CGRect frame, UIColor *backgroundColor, UIImage *image, CGFloat layerCornerRadius);

extern UIImageView *RJCreateSimpleImageView(CGRect frame,  UIImage *image);

#pragma mark - UITableView
extern UITableView *RJCreateTableView(CGRect frame, id<UITableViewDelegate> delegate, id<UITableViewDataSource> dataSource);

#pragma mark - UIScrollView
extern UIScrollView *RJCreateScrollView(CGRect frame);

#pragma mark - UIAlert
extern void ShowAlert(NSString *title, NSString *message,  NSString *button, UIViewController *vc);

#if defined __cplusplus
};
#endif


#endif
