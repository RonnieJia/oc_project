//

#import "NotesTableViewCell.h"
#import "RescueModel.h"
#import "ReservationModel.h"
#import "RepairModel.h"
#import "FixModel.h"

@interface NotesTableViewCell ()
@end

@implementation NotesTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIndentifier = @"NotesTableViewCell";
    NotesTableViewCell *cell = (NotesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(nil == cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIndentifier owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.containerView.layer.borderColor = KSepLineColor.CGColor;
        cell.containerView.layer.borderWidth=1.0;
        cell.containerView.layer.shadowColor = KTextDarkColor.CGColor;
        // 阴影偏移，默认(0, -3)
        cell.containerView.layer.shadowOffset = CGSizeMake(0,3);
        // 阴影透明度，默认0
        cell.containerView.layer.shadowOpacity = 0.3;
        // 阴影半径，默认3
        cell.containerView.layer.shadowRadius = 2;
        cell.leftBtn.layer.borderWidth=1.0;
        cell.leftBtn.layer.borderColor = KTextGrayColor.CGColor;
    }
    return cell;
}

- (void)setFixModel:(FixModel *)fixModel {
    _fixModel = fixModel;
    if (fixModel.fixState == 0) {
        fixModel.fixState = fixModel.order_state;
    }
    [self.iconImgView rj_setImageWithPath:fixModel.r_portrait placeholderImage:KDefaultImg];
    self.priceLabel.hidden = NO;
    self.dateLabel.text = getStringFromTimeintervalString(fixModel.create_time, @"yyyy-MM-dd");
    self.nameLabel.text = fixModel.r_name;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",fixModel.price];
    self.infoLabel.text = fixModel.v_name;
    self.linkView.hidden = (fixModel.fixState != FixStateWait);
    if (fixModel.is_cooperation==1) {
        self.flagView.hidden=NO;
        self.flagWidth.constant = 38;
    } else {
        self.flagWidth.constant=0;
        self.flagView.hidden=YES;
    }
    [self.leftBtn setTitle:@"取消订单" forState:UIControlStateNormal];
    switch (fixModel.fixState) {
        case FixStateWait:
        {
            [self.linkLBtn setTitle:@" 联系车主" forState:UIControlStateNormal];
            [self.linkRBtn setTitle:@" 定位车主" forState:UIControlStateNormal];
            [self.linkLBtn setImage:[UIImage imageNamed:@"iphone003"] forState:UIControlStateNormal];
            [self.linkRBtn setImage:[UIImage imageNamed:@"position004"] forState:UIControlStateNormal];
            self.finishDataLabel.hidden=YES;
            if (fixModel.is_offer==1) {
                self.rightBtn.hidden = YES;
                self.leftBtnTrailing.constant = 10;
                self.stateLabel.text = @"已报价";
            } else {
                self.priceLabel.hidden = YES;
                self.stateLabel.text = @"等待接单";
                [self.rightBtn setTitle:@"报价" forState:UIControlStateNormal];
            }
        }
            break;
        case FixStateAccept:
        {
            self.finishDataLabel.hidden=YES;
            if (fixModel.repair_state != 2) {
                self.stateLabel.text = @"维修中";
                [self.rightBtn setTitle:@"维修完成" forState:UIControlStateNormal];
            } else {
                self.leftBtn.hidden=self.rightBtn.hidden=YES;
                self.stateLabel.text = @"等待车主付款";
            }
        }
            break;
        case FixStateComplete:
        {
            self.leftBtn.hidden = self.rightBtn.hidden = YES;
            self.stateLabel.text = @"已完成";
            self.finishDataLabel.text = [NSString stringWithFormat:@"%@ 完成",getStringFromTimeintervalString(fixModel.create_time, @"yyyy-MM-dd")];
        }
            break;
        case FixStateCancel:
        {
            self.leftBtn.hidden = self.rightBtn.hidden = YES;
            self.stateLabel.text = fixModel.cancel_state==1?@"车主取消":@"维修点取消";
            self.finishDataLabel.text = [NSString stringWithFormat:@"%@ 取消",getStringFromTimeintervalString(fixModel.cancel_time, @"yyyy-MM-dd")];
        }
            break;
        default:
            break;
    }
}

-(void)setRepairModel:(RepairModel *)repairModel {
    _repairModel = repairModel;
    [self.iconImgView rj_setImageWithPath:repairModel.o_portrait placeholderImage:KDefaultImg];
    self.linkView.hidden = (repairModel.re_repair_state != RepairStateWait);
    self.nameLabel.text = repairModel.v_name;
    self.infoLabel.text = [NSString stringWithFormat:@"司机%@",repairModel.o_nickname];
    self.dateLabel.text = getStringFromTimeintervalString(repairModel.create_time, @"yyyy-MM-dd");
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@",repairModel.re_price];
    if (repairModel.is_cooperation==1) {// 合作过
        self.flagView.hidden=NO;
        self.flagWidth.constant = 38;
    } else {
        self.flagWidth.constant=0;
        self.flagView.hidden=YES;
    }
    NSString *stateString;
    switch (repairModel.re_repair_state) {
        case RepairStateWait:
        {
            stateString = repairModel.is_offer==1?@"已报价，等待车厂付款":@"等待接单";
            self.finishDataLabel.hidden=YES;
            if (repairModel.is_offer==1) {
                self.rightBtn.hidden=YES;
                self.leftBtn.hidden=YES;
            } else {
                self.priceLabel.hidden=YES;
                [self.rightBtn setTitle:@"报价" forState:UIControlStateNormal];
            }
        }
            break;
        case RepairStateAccept:// 维修中
        {
            stateString = @"维修中";
            self.finishDataLabel.hidden = self.leftBtn.hidden = self.rightBtn.hidden = YES;
        }
            break;
        case RepairStateComplete:// 已完成
        {
            stateString = @"已完成";
            self.leftBtn.hidden = self.rightBtn.hidden = YES;
            self.finishDataLabel.text = [NSString stringWithFormat:@"%@ 完成",getStringFromTimeintervalString(repairModel.complete_time, @"yyyy-MM-dd")];
        }
            break;
        case RepairStateCancel:// 已取消
        {
            stateString = repairModel.cancel_state==1?@"车主取消":@"维修点取消";
            self.priceLabel.hidden=self.leftBtn.hidden = self.rightBtn.hidden = YES;
            self.finishDataLabel.text = [NSString stringWithFormat:@"%@ 取消",getStringFromTimeintervalString(repairModel.cancel_time, @"yyyy-MM-dd")];
        }
            break;
        case RepairStateRefuse:
        {
            if (repairModel.is_trailer_confirm==2) {
                stateString = @"挂车厂不认可";
            } else if (repairModel.is_repair_confirm==2) {
                stateString = @"维修点不认可";
            } else {
                stateString = @"平台不认可";
            }
            self.priceLabel.hidden=self.leftBtn.hidden = self.rightBtn.hidden = YES;
            self.finishDataLabel.text = [NSString stringWithFormat:@"%@ 否认",getStringFromTimeintervalString(repairModel.no_approval_time1, @"yyyy-MM-dd")];
        }
            break;
            
        default:
            break;
    }
    self.stateLabel.text = stateString;
}

- (void)setReservationModel:(ReservationModel *)reservationModel {
    _reservationModel = reservationModel;
    [self.iconImgView rj_setImageWithPath:reservationModel.o_portrait placeholderImage:KDefaultImg];
    self.nameLabel.text = reservationModel.v_name;
    self.infoLabel.text = reservationModel.o_nickname;
    self.dateLabel.text = getStringFromTimeintervalString(reservationModel.create_time, @"yyyy-MM-dd");
    self.stateLabel.text = [NSString stringWithFormat:@"%@ 到店",getStringFromTimeintervalString(reservationModel.a_time, @"yyyy-MM-dd")];
    if (reservationModel.is_cooperation==1) {
        self.flagView.hidden=NO;
        self.flagWidth.constant = 38;
    } else {
        self.flagWidth.constant=0;
        self.flagView.hidden=YES;
    }
    switch (reservationModel.reservationState) {
        case ReservationStateWait:
        {
            self.linkView.hidden=NO;
            self.priceLabel.hidden = self.leftBtn.hidden = self.rightBtn.hidden = self.finishDataLabel.hidden = YES;
            [self.linkLBtn setTitle:@" 接单" forState:UIControlStateNormal];
            [self.linkRBtn setTitle:@" 拒绝" forState:UIControlStateNormal];
            [self.linkLBtn setImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
            [self.linkRBtn setImage:[UIImage imageNamed:@"noaccept"] forState:UIControlStateNormal];
        }
            break;
        case ReservationStateAccept:
        {
            self.linkView.hidden=YES;
            self.priceLabel.hidden = self.leftBtn.hidden = self.rightBtn.hidden = self.finishDataLabel.hidden = YES;
        }
            break;
        case ReservationStateRefuse:
        {
            self.stateLabel.text = [NSString stringWithFormat:@"%@ 拒绝",getStringFromTimeintervalString(reservationModel.a_time, @"yyyy-MM-dd")];
            self.priceLabel.hidden = self.leftBtn.hidden = self.rightBtn.hidden = self.finishDataLabel.hidden = YES;
        }
            break;
        default:
            break;
    }
}


- (void)setRescueModel:(RescueModel *)rescueModel {
    _rescueModel = rescueModel;
    self.nameLabel.text = rescueModel.v_name;
    self.infoLabel.text = [NSString stringWithFormat:@"司机%@",rescueModel.r_name];
    self.dateLabel.text = getStringFromTimeintervalString(rescueModel.create_time, @"yyyy-MM-dd");
    [self.iconImgView rj_setImageWithPath:rescueModel.o_portrait placeholderImage:KDefaultImg];
    if (rescueModel.cooperation==1) {
        self.flagView.hidden=NO;
        self.flagWidth.constant = 38;
    } else {
        self.flagWidth.constant=0;
        self.flagView.hidden=YES;
    }
    switch (rescueModel.rescueState) {
        case RescueStateWait:
        {
            self.linkView.hidden=NO;
            self.priceLabel.hidden = self.stateLabel.hidden = self.leftBtn.hidden = self.rightBtn.hidden = self.finishDataLabel.hidden = YES;
            [self.linkLBtn setTitle:@" 接单" forState:UIControlStateNormal];
            [self.linkRBtn setTitle:@" 拒绝" forState:UIControlStateNormal];
            [self.linkLBtn setImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
            [self.linkRBtn setImage:[UIImage imageNamed:@"noaccept"] forState:UIControlStateNormal];
        }
            break;
        case RescueStateAccept:
        {
            self.linkView.hidden=self.stateLabel.hidden = NO;
            self.priceLabel.hidden = self.leftBtn.hidden = self.finishDataLabel.hidden = YES;
            self.rightBtn.hidden = NO;
            if (rescueModel.repair_state == 0) {//已接单
                if (rescueModel.is_offer==0) {
                    [self.rightBtn setTitle:@"到达现场" forState:UIControlStateNormal];
                    self.stateLabel.text = @"已接单";
                } else {
                    self.stateLabel.text = @"已报价";
                    self.rightBtn.hidden=YES;
                }
            } else if (rescueModel.repair_state == 1) {//维修中（同意维修）
                [self.rightBtn setTitle:@"维修完成" forState:UIControlStateNormal];
                self.stateLabel.text=@"维修中";
            } else {//2维修完成等待付款
                self.rightBtn.hidden =YES;
                self.stateLabel.text = @"等待车主付款";
            }
            [self.linkLBtn setTitle:@" 联系车主" forState:UIControlStateNormal];
            [self.linkRBtn setTitle:@" 定位车主" forState:UIControlStateNormal];
            [self.linkLBtn setImage:[UIImage imageNamed:@"iphone003"] forState:UIControlStateNormal];
            [self.linkRBtn setImage:[UIImage imageNamed:@"position004"] forState:UIControlStateNormal];
        }
            break;
        case RescueStateFinish:
        {
            self.linkView.hidden=YES;
            self.priceLabel.hidden = NO;
            self.stateLabel.hidden = NO;
            self.stateLabel.text = @"已完成";
            self.leftBtn.hidden = self.rightBtn.hidden = self.finishDataLabel.hidden = YES;
        }
            break;
        case RescueStateRefuse:
        {
            self.linkView.hidden=YES;
            self.stateLabel.hidden = NO;
            self.stateLabel.text = @"已拒绝";
            self.priceLabel.hidden = self.leftBtn.hidden = self.rightBtn.hidden = self.finishDataLabel.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}


- (IBAction)receiptBtnAction:(UIButton *)sender {
    weakify(self);
    if (self.rescueModel) {
        if (self.rescueModel.rescueState == RescueStateWait) {// 接单
            WaittingMBProgressHUD(KKeyWindow, @"");
            [kRJHTTPClient rescue:self.rescueModel.r_id receipt:YES completion:^(WebResponse *response) {
                if ((response.code == WebResponseCodeSuccess)) {
                    if (weakSelf.rescueAcceptBlock) {
                        weakSelf.rescueAcceptBlock(weakSelf.rescueModel);
                    }
                }
                FailedMBProgressHUD(KKeyWindow, response.message);
            }];
        } else if (self.rescueModel.rescueState == RescueStateAccept) {
            makePhoneCall(self.rescueModel.o_number);
        }
    } else if (self.reservationModel) {// 预约订单
           if (self.reservationModel.reservationState == ReservationStateWait) {//待接单
               WaittingMBProgressHUD(KKeyWindow, @"");
               [kRJHTTPClient reservation:self.reservationModel.r_id receipt:YES completion:^(WebResponse *response) {
                   if ((response.code == WebResponseCodeSuccess)) {
                       if (self.rescueAcceptBlock) {
                           self.rescueAcceptBlock(self.reservationModel);
                       }
                   }
                    FailedMBProgressHUD(KKeyWindow, response.message);
               }];
           }
    } else if (self.fixModel) {// 维修订单
        if (self.fixModel.fixState == FixStateWait) {// 联系车主
            makePhoneCall(self.fixModel.phone);
        }
    } else if (self.repairModel) {// 报修订单
       if (self.repairModel.re_repair_state == RepairStateWait) {// 联系车主
           if (self.rescueAcceptBlock) {
               self.rescueAcceptBlock(self.repairModel);
           }
       }
   }
}

- (IBAction)refuseButtonAction:(UIButton *)sender {
    if (self.rescueModel) {
        if (self.rescueModel.rescueState == RescueStateWait) {// 接单
            WaittingMBProgressHUD(KKeyWindow, @"");
            weakify(self);
            [kRJHTTPClient rescue:self.rescueModel.r_id receipt:NO completion:^(WebResponse *response) {
                if ((response.code == WebResponseCodeSuccess)) {
                    if (weakSelf.rescueRefuseBlock) {
                        weakSelf.rescueRefuseBlock(weakSelf.rescueModel);
                    }
                }
                FailedMBProgressHUD(KKeyWindow, response.message);
            }];
        } else if (self.rescueModel.rescueState == RescueStateAccept) {// 定位车主
            if (self.locationBlock) {
                self.locationBlock(self.rescueModel);
            }
        }
    } else if (self.reservationModel) {// 预约订单
        if (self.reservationModel.reservationState == ReservationStateWait) {//待接单
            WaittingMBProgressHUD(KKeyWindow, @"");
            [kRJHTTPClient reservation:self.reservationModel.r_id receipt:NO completion:^(WebResponse *response) {
                if ((response.code == WebResponseCodeSuccess)) {
                    if (self.rescueRefuseBlock) {
                        self.rescueRefuseBlock(self.reservationModel);
                    }
                }
                FailedMBProgressHUD(KKeyWindow, response.message);
            }];
        }
    } else if (self.fixModel) {// 维修订单
       if (self.fixModel.fixState == FixStateWait) {// 定位车主
           if (self.locationBlock) {
               self.locationBlock(self.fixModel);
           }
       }
    } else if (self.repairModel) {// 报修订单
        if (self.repairModel.re_repair_state == RepairStateWait) {// 联系平台
            if (self.locationBlock) {
                self.locationBlock(self.repairModel);
            }
        }
    }
}
- (IBAction)rightBtnAction:(UIButton *)sender {
    if (self.fixModel) {// 维修订单
        if (self.fixModel.fixState == FixStateWait) {// 报价
            if (self.rightBtnBlock) {
                self.rightBtnBlock(self.fixModel);
            }
        }else if (self.fixModel.fixState == FixStateAccept) {
            if (self.fixModel.repair_state!=2) {// 维修中-点击维修完成
                WaittingMBProgressHUD(KKeyWindow, @"");
                weakify(self);
                [kRJHTTPClient fixComplete:self.fixModel.order_rid completion:^(WebResponse *response) {
                    if (response.code == WebResponseCodeSuccess) {
                        weakSelf.fixModel.repair_state=2;
                        weakSelf.leftBtn.hidden=weakSelf.rightBtn.hidden=YES;
                        weakSelf.stateLabel.text = @"等待车主付款";
                    }
                    FailedMBProgressHUD(KKeyWindow, response.message);
                }];
            }
        }
    } else if (self.repairModel) {
        if (self.repairModel.re_repair_state == RepairStateWait) {
            if (self.repairModel.is_offer!=1) {// 报价
                if (self.rightBtnBlock) {
                    self.rightBtnBlock(self.repairModel);
                }
            }
        }
    }
}
- (IBAction)leftBtnAction:(UIButton *)sender {
    if (self.fixModel) {// 维修订单、取消订单
        if (self.leftBtnBlock) {
            self.leftBtnBlock(self.fixModel);
        }
    } else if (self.repairModel) {
        if (self.leftBtnBlock) {
            self.leftBtnBlock(self.repairModel);
        }
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
