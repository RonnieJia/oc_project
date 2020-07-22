#import "AgreeViewController.h"
#import "HTTPWebAPIUrl.h"
#import <WebKit/WebKit.h>

@interface AgreeViewController ()<WKNavigationDelegate>
@property (nonatomic, strong)WKWebView *webVew;
@property(nonatomic, strong)UIScrollView *scrollView;
@end

@implementation AgreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButton];
    self.view.backgroundColor = KTextWhiteColor;
    if (self.yinsi) {
        self.title = @"隐私政策";
    } else {
        self.title = @"用户协议";
    }
    [self fetchAgreement];
//    WaittingMBProgressHUD(KKeyWindow, @"");
//    [self.webVew loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@register_info",kBaseUrl]]]];
}
- (void)fetchAgreement {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    [kRJHTTPClient fetchUserAgreementYinsi:self.yinsi completion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf loadWebView:StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)loadWebView:(NSString *)str {
    [self.view addSubview:self.webVew];
    NSString *head = [NSString stringWithFormat:@"<head><style>img{max-width:%dpx !important;}</style></head>",(int)self.view.width-16];
    [self.webVew loadHTMLString:[head stringByAppendingString:htmlString(str)] baseURL:[NSURL URLWithString:KImgBaseUrl]];
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
    }
    return _scrollView;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    FinishMBProgressHUD(KKeyWindow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    FailedMBProgressHUD(KKeyWindow, @"加载失败");
}

- (WKWebView *)webVew {
    if (!_webVew) {
        _webVew = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
        _webVew.navigationDelegate = self;
        _webVew.backgroundColor = [UIColor clearColor];
    }
    return _webVew;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
