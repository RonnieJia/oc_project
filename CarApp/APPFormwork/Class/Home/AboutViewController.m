#import "AboutViewController.h"

@interface AboutViewController ()<UIWebViewDelegate>
@property(nonatomic, strong)UIWebView *webView;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于我们";
    [self setBackButton];
    [self fetchData];
}

- (void)fetchData {
    WaittingMBProgressHUD(self.view, @"");
    weakify(self);
    self.clientDataTask = [kRJHTTPClient fetchAboutCompletion:^(WebResponse *response) {
        if (response.code == WebResponseCodeSuccess) {
            [weakSelf creatMainView:StringForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(ObjForKeyInUnserializedJSONDic(response.responseObject, @"result"), @"info"), @"c_about_repair")];
            FinishMBProgressHUD(weakSelf.view);
        } else {
            FailedMBProgressHUD(weakSelf.view, response.message);
        }
    }];
}

- (void)creatMainView:(NSString *)html {
    [self setScrollViewAdjustsScrollViewInsets:self.webView.scrollView];
    [self.view addSubview:self.webView];
    
    NSString *head = [NSString stringWithFormat:@"<head><style>img{max-width:%dpx !important;}</style></head>",(int)self.view.width-16];
    [self.webView loadHTMLString:[head stringByAppendingString:htmlString(html)] baseURL:[NSURL URLWithString:KImgBaseUrl]];
}


- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KViewNavHeight)];
        _webView.scrollView.delegate=self;
        _webView.backgroundColor = KTextWhiteColor;
        _webView.tintColor = KTextWhiteColor;
        _webView.delegate=self;
        _webView.opaque = NO;
    }
    return _webView;
}
@end
