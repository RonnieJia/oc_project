//

#import "RJBaseTableViewCell.h"
@class RescueModel;
@class ReservationModel;
@class RepairModel;
@class FixModel;

NS_ASSUME_NONNULL_BEGIN

@interface NotesTableViewCell : RJBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIView *flagView;
@property (weak, nonatomic) IBOutlet UIView *linkView;
@property (weak, nonatomic) IBOutlet UIButton *linkLBtn;
@property (weak, nonatomic) IBOutlet UIButton *linkRBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flagWidth;


@property (nonatomic, strong) RescueModel *rescueModel;
@property (nonatomic, strong) ReservationModel *reservationModel;
@property (nonatomic, strong) RepairModel *repairModel;
@property (nonatomic, strong) FixModel *fixModel;// 维修订单


@property(nonatomic, copy)void(^locationBlock)(id obj);
@property(nonatomic, copy)void(^rightBtnBlock)(id obj);
@property(nonatomic, copy)void(^leftBtnBlock)(id obj);
@property(nonatomic, copy)void(^rescueRefuseBlock)(id obj);
@property(nonatomic, copy)void(^rescueAcceptBlock)(id obj);
@end

NS_ASSUME_NONNULL_END
