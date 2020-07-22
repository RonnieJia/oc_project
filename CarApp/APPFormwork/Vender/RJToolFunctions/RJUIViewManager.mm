
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

UIView *RJCreateView(CGRect frame, UIColor *backgroundColor, BOOL clips, CGFloat layerCornerRadius, UIColor *borderColor, CGFloat borderWidth) {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    if (clips) {
        view.clipsToBounds = clips;
    }
    if (borderColor && borderWidth>0) {
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor.CGColor;
    }
    if (layerCornerRadius > 0) {
        view.layer.cornerRadius = layerCornerRadius;
    }
    if (backgroundColor) {
        view.backgroundColor = backgroundColor;
    }
    return view;
}

UIView *RJCreateSimpleView(CGRect frame, UIColor *backgroundColor) {
    return RJCreateView(frame, backgroundColor, NO, 0, nil, 0);
}

UILabel *RJCreateLable(CGRect frame, UIFont *font, UIColor *color, NSTextAlignment textAlignment, NSString *text) {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.textColor = color;
    label.textAlignment = textAlignment;
    if (text && ![text isKindOfClass:[NSNull class]]) {
        if ([text isKindOfClass:[NSString class]]) {
            label.text = text;
        } else {
            label.text = [NSString stringWithFormat:@"%@",text];
        }
    }
    return label;
}

UILabel *RJCreateDefaultLable(CGRect frame, UIFont *font, UIColor *color, NSString *text) {
    UILabel *label = RJCreateLable(frame, font, color, NSTextAlignmentLeft, text);
    return label;
}

UIButton *RJCreateButton(CGRect frame, UIFont *font, UIColor *textColor, UIColor *backgroundColor, UIImage *backgroundImg, UIImage *image, NSString *title) {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (font) {
        btn.titleLabel.font = font;
    }
    if (textColor) {
        [btn setTitleColor:textColor forState:UIControlStateNormal];
    }
    if (backgroundColor) {
        btn.backgroundColor = backgroundColor;
    }
    if (backgroundImg) {
        [btn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    }
    if (image) {
        [btn setImage:image forState:UIControlStateNormal];
    }
    if (title) {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    
    return btn;
}

UIButton *RJCreateTextButton(CGRect frame, UIFont *font, UIColor *textColor, UIImage *backgroundImg, NSString *title) {
    return RJCreateButton(frame, font, textColor, nil, backgroundImg, nil, title);
}

UIButton *RJCreateImageButton(CGRect frame, UIImage *normalImage, UIImage *selectImage) {
    UIButton *btn = RJCreateButton(frame, nil, nil, nil, nil, normalImage, nil);
    if (selectImage) {
        [btn setImage:selectImage forState:UIControlStateSelected];
    }
    return btn;
}


UITextField *RJCreateTextField(CGRect frame, UIFont *font, UIColor *textColor, UIColor *placeholderColor, UIColor *backgroundColor, UIView *left, UIView *right, BOOL secure, NSString *placeholder, NSString *text) {
    UITextField *tf = [[UITextField alloc] initWithFrame:frame];
    if (font) {
        tf.font = font;
    }
    if (textColor) {
        tf.textColor = textColor;
    }
    if (placeholder) {
        tf.placeholder = placeholder;
//        if (placeholderColor) {
//            [tf setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
//        }
    }
    if (backgroundColor) {
        tf.backgroundColor = backgroundColor;
    }
    if (secure) {
        tf.secureTextEntry=secure;
    }
    if (text) {
        tf.text = text;
    }
    if (left) {
        tf.leftView = left;
        tf.leftViewMode = UITextFieldViewModeAlways;
    }
    if (right) {
        tf.rightView = right;
        tf.rightViewMode = UITextFieldViewModeAlways;
    }
    return tf;
}

UITextField *RJCreateSimpleTextField(CGRect frame, UIFont *font, UIColor *textColor, NSString *placeholder, NSString *text) {
    return RJCreateTextField(frame, font, textColor, nil, nil, nil, nil, NO, placeholder, text);
}

UIImageView *RJCreateImageView(CGRect frame, UIColor *backgroundColor, UIImage *image, CGFloat layerCornerRadius) {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    if (backgroundColor) {
        imageView.backgroundColor = backgroundColor;
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    if (layerCornerRadius>0) {
        imageView.layer.cornerRadius = layerCornerRadius;
        imageView.clipsToBounds=YES;
    }
    if (image) {
        imageView.image = image;
    }
    return imageView;
}

UIImageView *RJCreateSimpleImageView(CGRect frame,  UIImage *image) {
    return RJCreateImageView(frame, nil, image, 0);
}

UITableView *RJCreateTableView(CGRect frame, id<UITableViewDelegate> delegate, id<UITableViewDataSource> dataSource) {
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
    tableView.delegate = delegate;
    tableView.dataSource = dataSource;
    return tableView;
}

UIScrollView *RJCreateScrollView(CGRect frame) {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    return scrollView;
}

void ShowAlert(NSString *title, NSString *message,  NSString *button, BOOL cancel, UIViewController *vc) {
    if (vc) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (button) {
            [alert addAction:[UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
        }
        
        
        [vc presentViewController:alert animated:YES completion:nil];
    }
    
}
