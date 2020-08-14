//
//  SGViewController.m
//  SGTools
//
//  Created by GuiLQing on 07/12/2019.
//  Copyright (c) 2019 GuiLQing. All rights reserved.
//

#import "SGViewController.h"
#import "SGVocabularyDictationView.h"
#import <Masonry/Masonry.h>
#import "SGSearchController.h"
#import "SGMacorsConfig.h"
#import "SGVideoPlayer.h"
#import "SGAlertView.h"
#import "SGCountDownView.h"

static inline BOOL SG_IS_IPAD(void) {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

#define SG_SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define SG_SCREEN_HEIGHT       ([UIScreen mainScreen].bounds.size.height)

@interface SGViewController ()

@end

@implementation SGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
	// Do any additional setup after loading the view, typically from a nib.
    
    SGCountDownView *countDownView = [[SGCountDownView alloc] init];
    [self.view addSubview:countDownView];
    [countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(150.0f);
        make.size.mas_equalTo(countDownView.frame.size);
    }];
    
    CGFloat dictationViewWidth = SG_IS_IPAD() ? (SG_SCREEN_WIDTH * 0.7) : (SG_SCREEN_WIDTH - 40.0f);
    SGVocabularyDictationView *dicView = [[SGVocabularyDictationView alloc] initWithFrame:CGRectMake(20.0f, 0, dictationViewWidth, 0)];
    dicView.vocabulary = @"take a tour";
    [self.view addSubview:dicView];
    [dicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(countDownView.mas_bottom).offset(30.0f);
        make.left.equalTo(self.view).offset(20.0f);
        make.right.equalTo(self.view).offset(-20.0f);
    }];

    dicView.viewType = SGDictationViewTypeNone;
//    dicView.sg_dictationVoiceDidClicked = ^(void (^ _Nonnull handleVoiceAnimation)(BOOL)) {
//        handleVoiceAnimation(YES);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            handleVoiceAnimation(NO);
//        });
//    };
    
    
//    SGLog(@"%@---%d---%lf", @"hahha", 555, 8293.0f);
//
//    NSLog(@"%@", SG_PathLibraryAppend(nil));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    SGSearchController *searchVC = [[SGSearchController alloc] initWithDefaultText:@"" placeholderText:@"hahaha" historySaveKey:@""];
//    [self.navigationController pushViewController:searchVC animated:YES];
    
//    SGAlertViewLancooSubmitShow(@"温馨提示", @"      您可以通过课前预习、课后作业、测试及做习题等其他途径，提高掌握的词汇数量。", @"确定", @"取消", ^(void) {
//        NSLog(@"确定");
//    }, nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
