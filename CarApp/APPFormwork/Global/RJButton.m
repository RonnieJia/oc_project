

#import "RJButton.h"

@implementation RJButton
+ (instancetype)buttonWithFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)font image:(UIImage *)norImg selectImage:(UIImage *)selImg target:(id)target selector:(SEL)selector {
    RJButton *btn = [super buttonWithFrame:frame title:title titleColor:titleColor titleFont:font image:norImg selectImage:selImg target:target selector:selector];
    [btn initialOptions];
    return btn;
}

- (void)initialOptions {
    self.margin = 10.0f;
    self.type = RJButtonTypeTitleRight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    switch (self.type) {
        case RJButtonTypeTitleRight:
        {
            
            if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
                self.titleLabel.right = self.width;
                self.imageView.right = self.titleLabel.left - self.margin;
            } else {
                self.titleLabel.left = self.imageView.right + self.margin;
            }
            
        }
            break;
        case RJButtonTypeTitleLeft:
        {
            
            UIEdgeInsets inset = self.contentEdgeInsets;
            if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight) {
                self.imageView.right = self.width-inset.right;
                self.titleLabel.right = self.imageView.left - self.margin;
            } else if (self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft) {
                self.titleLabel.left = inset.left;
                self.titleLabel.centerY = self.height/2.0;
                self.imageView.left = self.titleLabel.right+self.margin;
            } else {
                if (self.currentImage) {
                    CGFloat left = (self.width-self.titleLabel.width-self.margin-self.imageView.width)/2.0;
                    self.titleLabel.left = left;
                    self.imageView.left = self.titleLabel.right + 5;
                }
            }
        }
            break;
        case RJButtonTypeTitleBottom:
        {
            if (self.imageViewSize.width>0) {
                self.imageView.size = self.imageViewSize;
            }
            if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentCenter) {
                [self.titleLabel sizeToFit];
                self.imageView.top = (self.height - self.margin - self.titleLabel.height - self.imageView.height)/2.0;
                self.imageView.centerX = self.width/2.f;
                self.titleLabel.top = self.imageView.bottom + self.margin;
                self.titleLabel.centerX = self.width/2.0f;
            } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
                self.imageView.top = 0;
                self.imageView.centerX = self.width/2.f;
                [self.titleLabel sizeToFit];
                self.titleLabel.top = self.imageView.bottom + self.margin;
                self.titleLabel.centerX = self.width/2.0f;
            } else {
                self.imageView.top = 5;
                self.imageView.centerX = self.width/2.f;
                [self.titleLabel sizeToFit];
                self.titleLabel.top = self.imageView.bottom + self.margin;
                self.titleLabel.centerX = self.width/2.0f;
            }
        }
            break;
        case RJButtonTypeCustomMargin:
        {
            self.imageView.left = 0;
            self.titleLabel.left = self.margin;
        }
            break;
        case RJButtonTypeTitleBottomSize:
        {
                self.imageView.frame = CGRectMake((self.width - 30)/2.0, 10, 30, 30);
                [self.titleLabel sizeToFit];
                self.titleLabel.top = self.imageView.bottom + self.margin;
                self.titleLabel.centerX = self.width/2.0f;

        }
            break;
        case RJButtonTypeTwoCap:
        {
            self.titleLabel.left = 0;
            self.imageView.right = self.width;
        }
            break;
        default:
            break;
    }
}

- (void)setHighlighted:(BOOL)highlighted {}

@end
