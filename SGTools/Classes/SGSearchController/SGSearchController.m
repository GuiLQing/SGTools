//
//  SGSearchController.m
//  SGSearchController
//
//  Created by lg on 2019/7/8.
//  Copyright © 2019 lg. All rights reserved.
//

#import "SGSearchController.h"

@implementation NSBundle (SGSearchResource)

+ (NSString *)sgSearch_bundlePathWithName:(NSString *)name {
    NSString *path = [[NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"SGSearchController")] pathForResource:@"SGSearchController" ofType:@"bundle"]].resourcePath stringByAppendingPathComponent:name];
    return path;
}

@end

@interface SGSearchCell : UITableViewCell

@end

@implementation SGSearchCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
            CGRect frame = subview.frame;
            frame.origin.x = self.separatorInset.left;
            frame.size.width = self.frame.size.width - self.separatorInset.left;
            subview.frame =frame;
        }
    }
}

@end

@interface SGSearchTextField : UITextField

+ (instancetype)searchTextFieldWithPlaceholderStr:(NSString *)PlaceholderStr frame:(CGRect)frame;

@end

@implementation SGSearchTextField

+ (instancetype)searchTextFieldWithPlaceholderStr:(NSString *)PlaceholderStr frame:(CGRect)frame
{
    SGSearchTextField *textField = [[self alloc] initWithFrame:frame];
    textField.placeholder = PlaceholderStr;
    return textField;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSBundle sgSearch_bundlePathWithName:@"sg_icon_search"]]];
    imageView.contentMode = UIViewContentModeCenter;
    CGRect frame = imageView.frame;
    frame.size.width = imageView.frame.size.width + 10;
    imageView.frame = frame;
    self.backgroundColor = [UIColor whiteColor];
    self.tintColor = [UIColor colorWithRed:56/255.0 green:142/255.0 blue:195/255.0 alpha:1.0];
    self.font = [UIFont systemFontOfSize:14];
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.leftView = imageView;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.returnKeyType = UIReturnKeySearch;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
}

@end

@interface SGSearchController () <UITextFieldDelegate>

@property (nonatomic, copy) NSString *userDefaultKey;

@property (nonatomic, strong) SGSearchTextField *searchTextField;

@property (nonatomic, strong) NSMutableArray *histories;

@property (nonatomic, assign) BOOL isSeachBtnClicked;

@end

@implementation SGSearchController

- (instancetype)initWithDefaultText:(NSString *)defaultText placeholderText:(NSString *)placeholderText historySaveKey:(NSString *)historySaveKey {
    if (self = [super init]) {
        self.placeholderStr = placeholderText;
        self.searchTextField.text = defaultText;
        self.userDefaultKey = historySaveKey;
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchTextField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.isSeachBtnClicked == NO) {
        if (self.cancelCallBack) {
            self.cancelCallBack();
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSubViews];
    
    [self loadHistoryData];
}

- (void)loadHistoryData
{
    id histories = [[NSUserDefaults standardUserDefaults] objectForKey:self.userDefaultKey];
    self.histories = ((NSMutableArray *)histories).mutableCopy;
    if (self.histories.count == 0 || !self.histories) {
        
    }
    [self.tableView reloadData];
}

- (void)setUpSubViews
{
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    self.navigationItem.leftBarButtonItem = [self backItem];
    
    self.navigationItem.titleView = self.searchTextField;
    
    self.navigationItem.rightBarButtonItem = [self searchItem];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        return NO;
    }
    
    [self onSeachClick];
    
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.histories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"searchCell";
    SGSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[SGSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = self.histories[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIView *bgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, ScreenWidth, 40)];
    
    [btn setTitleColor:[UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1.0] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [btn addTarget:self action:@selector(onHistoryClick) forControlEvents:UIControlEventTouchUpInside];
    if (self.histories.count == 0) {
        [btn setTitle:@"暂无记录" forState:UIControlStateNormal];
        btn.userInteractionEnabled = NO;
    }else {
        [btn setTitle:@"清空历史记录" forState:UIControlStateNormal];
        btn.userInteractionEnabled = YES;
    }
    [bgView addSubview:btn];
    [btn sizeToFit];
    
    btn.center = bgView.center;
    
    return bgView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.searchTextField.text = self.histories[indexPath.row];
    [self.searchTextField becomeFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.histories removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.histories forKey:self.userDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}
#pragma mark - events
- (void)onSeachClick
{
    NSString *searchStr = self.searchTextField.text;
    
    if ([searchStr isEqualToString:@""]) return;
    
    [self saveSearchHistory:searchStr];
    
    if (self.searchCallBack) {
        self.searchCallBack(self.searchTextField.text);
    }
    
    self.isSeachBtnClicked = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onBack
{
    if (self.cancelCallBack) {
        self.cancelCallBack();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onHistoryClick
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否清空历史记录？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAct = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.searchTextField resignFirstResponder];
        [self.histories removeAllObjects];
        [self.tableView reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:self.histories.mutableCopy forKey:self.userDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:sureAct];
    [alertController addAction:cancelAct];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - private method
- (void)saveSearchHistory:(NSString *)searchStr
{
    for (NSString *history in self.histories) {
        if ([history isEqualToString:searchStr]) {
            [self.histories removeObject:history];
            break;
        }
    }
    [self.histories insertObject:searchStr atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:self.histories forKey:self.userDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - getters - setters
- (NSMutableArray *)histories
{
    if (!_histories) {
        _histories = [NSMutableArray array];
    }
    return _histories;
}

- (SGSearchTextField *)searchTextField
{
    if (!_searchTextField) {
        CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
        _searchTextField = [SGSearchTextField searchTextFieldWithPlaceholderStr:self.placeholderStr frame:CGRectMake(0, 0, ScreenWidth, 30)];
        
        _searchTextField.delegate = self;
    }
    return _searchTextField;
}

- (void)setPlaceholderStr:(NSString *)placeholderStr
{
    _placeholderStr = placeholderStr;
    self.searchTextField.placeholder = placeholderStr;
}

- (UIBarButtonItem *)backItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithImage:[UIImage imageNamed:[NSBundle sgSearch_bundlePathWithName:@"sg_icon_back"]]
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(onBack)];
    [item setTintColor:[UIColor whiteColor]];
    
    return item;
}

- (UIBarButtonItem *)searchItem
{
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    searchBtn.frame = CGRectMake(0, 0, 40, 30);
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(onSeachClick) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
}

@end
