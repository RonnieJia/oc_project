//
//  AddressListCell.m

#import "AddressListCell.h"
#import "AddressModel.h"

@implementation AddressListCell

- (void)setModel:(AddressModel *)model {
    _model = model;
    
    NSString *nameMobile = [NSString stringWithFormat:@"%@    %@",model.consigner,model.mobile];
    NSMutableAttributedString *att=[[NSMutableAttributedString alloc] initWithString:nameMobile];
    [att addAttribute:NSFontAttributeName value:kFontWithSmallestSize range:NSMakeRange(att.length-model.mobile.length, model.mobile.length)];
    [att addAttribute:NSForegroundColorAttributeName value:KTextDarkColor range:NSMakeRange(att.length-model.mobile.length, model.mobile.length)];
    self.nameLabel.attributedText = att;
    self.addressLabel.text = [NSString stringWithFormat:@"%@",model.address];
    self.selectImgView.hidden = !model.is_default;
}

-(void)setupViews{
    self.contentView.backgroundColor = KBackGroundColor;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 10, KScreenWidth-20, 70)];
    view.backgroundColor = KTextWhiteColor;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    [self.contentView addSubview:view];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 15, 20)];
    imageV.centerY = view.height/2;
    imageV.image = [UIImage imageNamed:@"position003"];
    [view addSubview:imageV];
    
    self.nameLabel = [UILabel labelWithFrame:CGRectMake(imageV.right+20, 13, view.width-85-imageV.right, 20) textColor:KTextBlackColor font:kFontWithSmallSize text:@"111111"];
    [view addSubview:self.nameLabel];
//    self.phoneLabel = [UILabel labelWithFrame:CGRectMake(self.nameLabel.right+5, 10, 100, 20) textColor:KTextDarkColor font:kFontWithDefaultSize text:@"22222"];
//    [view addSubview:self.phoneLabel];
    self.addressLabel = [UILabel labelWithFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom+10, self.nameLabel.width, 20) textColor:KTextDarkColor font:kFontWithSmallSize text:@"333333"];
    [view addSubview:self.addressLabel];
    

    self.deleteBtn = [UIButton buttonWithFrame:CGRectMake(view.width-30, 0, 30, 30) image:[UIImage imageNamed:@"delete001"] target:self action:@selector(btnClick:)];
    self.deleteBtn.centerY = view.height/2;
    self.deleteBtn.tag = 101;
    [view addSubview:self.deleteBtn];

    self.editBtn = [UIButton buttonWithFrame:CGRectMake(view.width-60, 0, 30, 30) image:[UIImage imageNamed:@"edit001"] target:self action:@selector(btnClick:)];
    self.editBtn.centerY = view.height/2;
    self.editBtn.tag = 100;
    [view addSubview:self.editBtn];
    
    self.selectImgView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width-26, 0, 26, 26)];
    self.selectImgView.image = [UIImage imageNamed:@"checked"];
    [view addSubview:self.selectImgView];
}

- (void)btnClick:(UIButton *)btn {
    if (self.editAddressBlock) {
        self.editAddressBlock(btn.tag, self.model);
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
