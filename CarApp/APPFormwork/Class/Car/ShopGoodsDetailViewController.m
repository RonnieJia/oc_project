#import "ShopGoodsDetailViewController.h"
#import "GoodsDetailBottomView.h"
#import "GoodsDetailInfoView.h"
#import "ShopGoodsModel.h"
#import "SkuChooseView.h"
#import "AddressListViewController.h"
#import "AddressModel.h"
#import "ChatViewController.h"
#import "ShopBuyNowPayViewController.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>

//static CGFloat const kBottomHeight = 46;

@interface ShopGoodsDetailViewController ()<UIWebViewDelegate, UIScrollViewDelegate>
@property(nonatomic, strong)UIWebView *webView;
@property(nonatomic, strong)GoodsDetailBottomView *bottomView;
@property(nonatomic, strong)GoodsDetailInfoView *infoView;
@property(nonatomic, strong)ShopGoodsModel  *goodsModel;
@property(nonatomic, strong)SkuChooseView *skuView;
@property(nonatomic, weak)UIView *navBarView;

@end

@implementation ShopGoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBarView];
    [self fetchDetail];
}

- (void)fetchDetail {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchGoodsDetail:self.goods_id completion:^(WebResponse *response) {
        strongify(weakSelf);
        if (response.code == WebResponseCodeSuccess) {
            strongSelf.goodsModel = [ShopGoodsModel goodsDetail:ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            [strongSelf creatMainView];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
    
}

- (void)creatMainView {
    [self setScrollViewAdjustsScrollViewInsets:self.webView.scrollView];
    [self.view addSubview:self.webView];
    
    NSString *head = [NSString stringWithFormat:@"<head><style>img{max-width:%dpx !important;}</style></head>",(int)self.view.width-16];
    [self.webView loadHTMLString:[head stringByAppendingString:htmlString(self.goodsModel.desc)] baseURL:[NSURL URLWithString:KImgBaseUrl]];
    self.infoView.top = -self.infoView.height;
    [self.webView.scrollView addSubview:self.infoView];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(self.infoView.height, 0, 0, 0);
    [self.view addSubview:self.bottomView];
    self.bottomView.goodsModel = self.goodsModel;
    [self.view bringSubviewToFront:self.navBarView];
    [self callback];
}

- (void)pushToChatView {
    weakify(self);
    [JMSGConversation createSingleConversationWithUsername:[NSString stringWithFormat:kPartsWord,self.goodsModel.parts_id] appKey:kPartsAppKey completionHandler:^(id resultObject, NSError *error) {
        if (!error && resultObject && [resultObject isKindOfClass:JMSGConversation.class]) {
            ChatViewController *chat = [[ChatViewController alloc] init];
            chat.conversation=resultObject;
            [weakSelf.navigationController pushViewController:chat animated:YES];
        } else {
            ShowAutoHideMBProgressHUD(self.view, @"打开聊天失败，请稍后再试");
        }
    }];
}

- (void)callback {
    weakify(self);
    self.bottomView.buyGoodsBlock = ^(NSInteger type) {
        strongify(weakSelf);
        [strongSelf.skuView showGoods:strongSelf.goodsModel buy:type==0];
    };
    self.bottomView.serviceChatBlock = ^{
        [weakSelf pushToChatView];
    };
    self.infoView.goodsBtnBlock = ^(NSInteger index) {
        strongify(weakSelf);
        if (index == 0) {
            strongSelf.skuView.chooseType = YES;
            [strongSelf.skuView showGoods:strongSelf.goodsModel buy:NO];
        } else if (index == 1) {
            AddressListViewController *list = [AddressListViewController new];
            list.chooseAddress=YES;
            list.addressBlock = ^(AddressModel * _Nonnull address) {
                strongSelf.infoView.addressLabel.text = address.address;
            };
            [strongSelf.navigationController pushViewController:list animated:YES];
        } else if (index == 2) {
            [strongSelf shareAction];
        }
    };
    self.skuView.block = ^(NSString * _Nonnull sku) {
        strongify(weakSelf);
        strongSelf.infoView.typeLabel.text = [NSString stringWithFormat:@"\"%@\"",sku];
    };
    self.skuView.buyNowCompletion = ^(ShopGoodsModel * _Nonnull model, NSInteger num, SkuModel * _Nonnull sku) {
        strongify(weakSelf);
        ShopBuyNowPayViewController *buyNow = [[ShopBuyNowPayViewController alloc] init];
        buyNow.num = num;
        buyNow.goodsModel = model;
        buyNow.sku = sku;
        buyNow.goodsModel = strongSelf.goodsModel;
        [strongSelf.navigationController pushViewController:buyNow animated:YES];
    };
}

- (void)shareAction {
    [UMSocialUIManager setPreDefinePlatforms:@[@(1),@(2),@(4),@(5)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        UMSocialMessageObject *obj = [UMSocialMessageObject messageObject];
        UMShareWebpageObject *webpage = [UMShareWebpageObject shareObjectWithTitle:@"瞪羚康达" descr:@"维修端" thumImage:KDefaultImg];
        webpage.webpageUrl = @"www.baidu.com";
        obj.shareObject = webpage;
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:obj currentViewController:self completion:nil];
    }];
}


- (void)createNavBarView {
    UIView *navBarView = RJCreateSimpleView(CGRectMake(0, 0, KScreenWidth, KNavBarHeight), [KThemeColor colorWithAlphaComponent:0]);
    [self.view addSubview:navBarView];
    [self.view bringSubviewToFront:navBarView];
    self.navBarView = navBarView;
    
    UIButton *backBtn = RJCreateImageButton(CGRectMake(0, StatusBarHeight, 44, 44), [UIImage imageNamed:@"back002_xl"], [UIImage imageNamed:@"back001"]);
    [navBarView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (GoodsDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[GoodsDetailBottomView alloc] init];
    }
    return _bottomView;
}
- (GoodsDetailInfoView *)infoView {
    if (!_infoView) {
        _infoView = [[GoodsDetailInfoView alloc] initWithGoods:self.goodsModel];
    }
    return _infoView;
}
- (SkuChooseView *)skuView {
    if (!_skuView) {
        _skuView = [SkuChooseView sharedInstance];
    }
    return _skuView;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-kIPhoneXBH-46)];
        _webView.scrollView.delegate=self;
        _webView.backgroundColor = KTextWhiteColor;
        _webView.tintColor = KTextWhiteColor;
        _webView.delegate=self;
        _webView.opaque = NO;
    }
    return _webView;
}
@end
