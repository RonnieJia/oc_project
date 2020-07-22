//
//  AddressListCell.h

#import "RJBaseTableViewCell.h"
@class AddressModel;

NS_ASSUME_NONNULL_BEGIN

@interface AddressListCell : RJBaseTableViewCell
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *phoneLabel;
@property(nonatomic,strong)UILabel *addressLabel;
@property(nonatomic,strong)UIButton *editBtn;
@property(nonatomic,strong)UIButton *deleteBtn;
@property(nonatomic,strong)UIImageView *selectImgView;

@property (nonatomic, strong) AddressModel *model;
@property (nonatomic, copy)void(^editAddressBlock)(NSInteger tag, AddressModel *model);
@end

NS_ASSUME_NONNULL_END
