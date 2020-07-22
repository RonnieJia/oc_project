

#import "SearchViewController.h"

@interface SearchViewController ()<UITextFieldDelegate>
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackButton];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth-90, 44)];
    self.navigationItem.titleView = titleView;
    
    UITextField *searchTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, titleView.width - 25, 30)];
    searchTF.layer.cornerRadius = 15.0f;
    searchTF.layer.borderColor = [KSepLineColor CGColor];
    searchTF.layer.borderWidth = 1.0f;
    [titleView addSubview:searchTF];
    searchTF.returnKeyType = UIReturnKeySearch;
    searchTF.backgroundColor = [UIColor colorWithHex:@"#F0F0F0"];
    searchTF.textColor = KTextDarkColor;
    searchTF.font = kFontWithSmallSize;
    self.searchTextField = searchTF;
    searchTF.delegate = self;
    
    UIButton *searchBtn = [UIButton buttonWithFrame:CGRectMake(5, 0, 30, 30) image:[UIImage imageNamed:@"tbk_search"] target:self action:NULL];
    searchTF.leftView = searchBtn;
    searchTF.leftViewMode = UITextFieldViewModeAlways;
    [searchBtn addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)searchAction{
    if (self.searchTextField.text.length > 0) {
        [self.searchTextField resignFirstResponder];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchAction];
    return NO;
}
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.searchTextField.placeholder = placeholder;
}

- (NSString *)searchWord {
    return self.searchTextField.text;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
