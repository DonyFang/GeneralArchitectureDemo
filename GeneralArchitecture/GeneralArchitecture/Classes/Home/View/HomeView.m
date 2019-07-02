//
//  HomeView.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/24.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "HomeView.h"
#import "HomeTableViewCell.h"
@interface HomeView()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,strong)UITableView *mineTableView;
@property (nonatomic, strong) NSMutableArray<HomeModel *> *homeListDataArray;
@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation HomeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}
- (void)initViews{
    [self addSubview:self.mineTableView];
    [self.mineTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
#pragma mark - public
- (void)requestHomeListSuccessWithArray:(NSArray<HomeModel *> *)array {
    if (array.count > 0) {
        if (self.currentPage == 1) {
            [self.homeListDataArray removeAllObjects];
        }
        [self.homeListDataArray addObjectsFromArray:array];
        [self.mineTableView reloadData];
        [self.mineTableView.mj_footer endRefreshing];
    } else {
        [self.mineTableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.mineTableView.mj_header endRefreshing];
}

- (void)requestHomeListFailed {
    self.currentPage = 0;
    [self.homeListDataArray removeAllObjects];
    [self.mineTableView reloadData];
    [self.mineTableView.mj_header endRefreshing];
    [self.mineTableView.mj_footer endRefreshing];
}
#pragma mark---- TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [HomeTableViewCell cellWithTableView:tableView];
    cell.model = self.homeListDataArray[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.homeListDataArray.count;
}

- (void)requestRefreshData{
    self.currentPage = 1;
    [self.delegate home:self requestHomeListWithPage:self.currentPage];

}

- (void)loadMoreData{
    self.currentPage ++;
    [self.delegate home:self requestHomeListWithPage:self.currentPage];
}

- (UITableView *)mineTableView{
    if (!_mineTableView) {
        if (iPhoneX) {
            _mineTableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        }else{
            _mineTableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        }
        _mineTableView.backgroundColor = [UIColor whiteColor];
        _mineTableView.delegate = self;
        _mineTableView.dataSource = self;
        _mineTableView.rowHeight = UITableViewAutomaticDimension;
        //设置分割线颜色
        _mineTableView.separatorColor = [UIColor lightGrayColor];
        _mineTableView.separatorInset = UIEdgeInsetsZero;
        //设置分割线满屏
        _mineTableView.estimatedRowHeight = 44;
        _mineTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestRefreshData)];
        _mineTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        [_mineTableView.mj_header beginRefreshing];
    }
    return _mineTableView;
}


- (NSMutableArray *)homeListDataArray{
    if (!_homeListDataArray) {
        _homeListDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _homeListDataArray;
}
- (NSUInteger)currentPage {
    if (!_currentPage) {
        _currentPage = 0;
    }
    return _currentPage;
}

@end
