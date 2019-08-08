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

@interface SGViewController ()

@end

@implementation SGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
	// Do any additional setup after loading the view, typically from a nib.
    
//    SGVocabularyDictationView *dicView = [[SGVocabularyDictationView alloc] initWithFrame:CGRectMake(40.0f, 100.0f, UIScreen.mainScreen.bounds.size.width - 80.0f, 0)];
//    dicView.vocabulary = @"words";
//    [self.view addSubview:dicView];
//    [dicView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(100.0f);
//        make.left.equalTo(self.view).offset(40.0f);
//        make.right.equalTo(self.view).offset(-40.0f);
//    }];
//
//
//    dicView.viewType = SGDictationViewTypeVoice;
//    dicView.sg_dictationVoiceDidClicked = ^(void (^ _Nonnull handleVoiceAnimation)(BOOL)) {
//        handleVoiceAnimation(YES);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            handleVoiceAnimation(NO);
//        });
//    };
    
    SGGLog(@"%@---%d---%lf", @"hahha", 555, 8293.0f);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SGSearchController *searchVC = [[SGSearchController alloc] initWithDefaultText:@"" placeholderText:@"hahaha" historySaveKey:@""];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
