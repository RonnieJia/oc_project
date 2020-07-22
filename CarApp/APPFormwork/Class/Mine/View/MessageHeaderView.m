//
//  MessageHeaderView.m

#import "MessageHeaderView.h"


@interface MessageHeaderView ()
@property(nonatomic, weak)UIButton *selectBtn;
@property(nonatomic, weak)UIView *contentView;
@end

@implementation MessageHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.size = CGSizeMake(KScreenWidth, 42);
        self.backgroundColor = kViewControllerBgColor;
        UIView *contentView = RJCreateSimpleView(CGRectMake(0, 5, KScreenWidth, 37), KTextWhiteColor);
        [self addSubview:contentView];
        self.contentView=contentView;
        
        NSArray *titles = @[@"全部",@"订单消息",@"系统消息"];
        for (int i = 0; i<titles.count; i++) {
            UIButton *item = RJCreateButton(CGRectMake(i*(KScreenWidth/3), 0, KScreenWidth/3.0, 35), kFontWithSmallSize, KTextDarkColor, nil, createImageWithColor(KTextWhiteColor), nil, titles[i]);
            item.tag = 100+i;
            [item setTitleColor:KTextWhiteColor forState:UIControlStateSelected];
            [item setBackgroundImage:[UIImage imageNamed:@"menuback001"] forState:UIControlStateSelected];
            [contentView addSubview:item];
            [item addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            item.adjustsImageWhenHighlighted=NO;
            [item addTarget:self action:@selector(buttonCancelHighlighted:) forControlEvents:UIControlEventAllEvents];
            if (i==0) {
                item.selected = YES;
                self.selectBtn = item;
                self.selectIndex=0;
            }
        }
        UIView *line=RJCreateSimpleView(CGRectMake(0, 40, KScreenWidth, 2), KThemeColor);
        [self addSubview:line];
        
    }
    return self;
}

- (void)buttonCancelHighlighted:(UIButton *)btn {
    btn.highlighted=NO;
}

- (void)buttonClick:(UIButton *)btn {
    if (btn.selected) {
        return;
    }
    _selectIndex = btn.tag-100;
    self.selectBtn.selected = NO;
    btn.selected = YES;
    self.selectBtn = btn;
    if (self.msgHeaderCallBack) {
        self.msgHeaderCallBack(btn.tag-100);
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex!=selectIndex) {
        _selectIndex = selectIndex;
        UIButton *btn = [self.contentView viewWithTag:100+selectIndex];
        self.selectBtn.selected = NO;
        self.selectBtn = btn;
        btn.selected=YES;
    }
}

@end
