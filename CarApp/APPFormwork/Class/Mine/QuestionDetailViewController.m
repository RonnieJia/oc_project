//
//  QuestionDetailViewController.m
//  APPFormwork
//
#import "QuestionDetailViewController.h"

@interface QuestionDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UILabel *dateL;
@property (weak, nonatomic) IBOutlet UILabel *contentL;

@end

@implementation QuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"常见问题";
    self.titleL.text = StringForKeyInUnserializedJSONDic(self.dic, @"q_title");
    self.contentL.text = StringForKeyInUnserializedJSONDic(self.dic, @"q_content");
    self.dateL.text = StringForKeyInUnserializedJSONDic(self.dic, @"m_time");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
