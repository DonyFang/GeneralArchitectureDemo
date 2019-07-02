//
//  HomeViewController.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "HomeViewModel.h"
#import "HomeView.h"
@interface HomeViewController ()<HomeViewDelegate>
@property(nonatomic,strong)HomeViewModel *dataViewModel;
@property(nonatomic,strong)HomeView *mainView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"notice";
    [self.view addSubview:self.mainView];
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

}
- (void)rw_initVaraies{
    self.dataViewModel = [[HomeViewModel alloc] init];

}
#pragma  HomeViewDelegate
- (void)home:(HomeView *)view requestHomeListWithPage:(NSInteger)page{
    FDWeakSelf(self);
    [self.dataViewModel setBlockWithReturnBlock:^(id returnValue) {
    FDStrongSelf(self);
        [self.mainView requestHomeListSuccessWithArray:self.dataViewModel.arrayData];
    } WithErrorBlock:^(id errorCode, NSString *message) {
    FDStrongSelf(self);
        [self.mainView requestHomeListFailed];
    } WithFailureBlock:^{
    FDStrongSelf(self);
         [self.mainView requestHomeListFailed];
    }];     
    NSString *pageS = [NSString stringWithFormat:@"%ld",page];
    [self.dataViewModel ga_getHomeDataFromeServerWith:pageS];
}
#pragma mark - getter

- (HomeView *)mainView {
    if (!_mainView) {
        _mainView = [HomeView new];
        _mainView.delegate = self;
    }
    return _mainView;
}
@end
