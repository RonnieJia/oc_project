

#import "NotesChangeView.h"
#import "Masonry.h"

@interface NotesChangeView ()
@property(nonatomic, strong)NSArray *itemsArray;
@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, weak)UIButton *selectedBtn;
@end

@implementation NotesChangeView

- (instancetype)initWithItems:(NSArray *)items {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    if (self) {
        self.backgroundColor = kViewControllerBgColor;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:scrollView];
        scrollView.showsHorizontalScrollIndicator=NO;
//        scrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.scrollView = scrollView;
        if (items && [items isKindOfClass:[NSArray class]] && items.count>0) {
            self.itemsArray = items;
            for (int i = 0; i<items.count; i++) {
                UIButton *item = RJCreateTextButton(CGRectZero, kFontWithSmallSize, KTextDarkColor, createImageWithColor(kViewControllerBgColor), [NSString stringWithFormat:@"%@(0)",items[i]]);
                [scrollView addSubview:item];
                item.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
                [item setTitleColor:KTextWhiteColor forState:UIControlStateSelected];
                [item setBackgroundImage:createImageWithColor(KThemeColor) forState:UIControlStateSelected];
                item.layer.cornerRadius = 13;
                item.clipsToBounds=YES;
                item.tag = 100+i;
                [item addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
                [item addTarget:self action:@selector(cancelButtonHighlighted:) forControlEvents:UIControlEventAllEvents];
                if (i==0) {
                    item.selected=YES;
                    self.selectedBtn = item;
                    [item mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.left.mas_equalTo(10);
                        make.top.mas_equalTo(12);
                        make.height.mas_equalTo(26);
                    }];
                } else {
                    UIButton *offBtn = [scrollView viewWithTag:99+i];
                    [item mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(offBtn.mas_right).offset(2);
                        make.top.mas_equalTo(12);
                        make.height.mas_equalTo(26);
                        if (i == items.count-1) {
                            make.right.mas_offset(-10);
                        }
                    }];
                }
                
            }
        }
    }
    return self;
}

- (void)cancelButtonHighlighted:(UIButton *)btn {
    btn.highlighted=NO;
}

- (void)itemClick:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    self.selectedBtn.selected=NO;
    btn.selected=YES;
    self.selectedBtn = btn;
    _selectIndex = btn.tag-100;
    if (self.notesCallBack) {
        self.notesCallBack(btn.tag-100);
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    if (self.selectedBtn.tag-100 != selectIndex) {
        self.selectedBtn.selected=NO;
        UIButton *btn = [self.scrollView viewWithTag:100+selectIndex];
        btn.selected=YES;
        self.selectedBtn = btn;
        
        CGFloat contentWid = self.scrollView.contentSize.width;
        if (contentWid<=KScreenWidth) {
            return;
        }
        if (btn.centerX>KScreenWidth/2.0) {
            if ((contentWid-KScreenWidth) > (btn.centerX-KScreenWidth/2.0)) {
                [self.scrollView setContentOffset:CGPointMake(btn.centerX-KScreenWidth/2.0, 0) animated:YES];
            } else {
                [self.scrollView setContentOffset:CGPointMake(contentWid-self.scrollView.width, 0) animated:YES];
            }
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

- (void)count:(NSInteger)count changeAtIndex:(NSInteger)index {
    UIButton *btn = [self.scrollView viewWithTag:100+index];
    if (btn && index<self.itemsArray.count && count>=0) {
        [btn setTitle:[NSString stringWithFormat:@"%@(%zd)",self.itemsArray[index], count] forState:UIControlStateNormal];
    }
}

- (void)setIndexCount:(NSArray *)indexCount {
    _indexCount = indexCount;
    if ([indexCount isKindOfClass:[NSArray class]]) {
        for (int i = 0; i<indexCount.count; i++) {
            [self count:[indexCount[i] integerValue] changeAtIndex:i];
        }
    }
}
@end
