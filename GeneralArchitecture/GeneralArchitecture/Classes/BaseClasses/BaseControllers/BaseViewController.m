//
//  BaseViewController.m
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import "BaseViewController.h"
#import "UIViewController+NavigationButton.h"
@interface BaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    if (self.navigationController) {
        //设置导航栏风格为白色  返回按钮之类的
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] init];
        barButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = barButtonItem;
        [self.navigationItem.backBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor clearColor]} forState:UIControlStateNormal];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    //设置页面手势返回（防止navigationBar设置了leftBarButton手势返回失效）
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //设置协议
    if ([self respondsToSelector:@selector(rw_initVaraies)]) {
        [self rw_initVaraies];
    }
    if ([self respondsToSelector:@selector(rw_initViews)]) {
        [self rw_initViews];
    }
    if ([self respondsToSelector:@selector(rw_initNetData)]) {
        [self rw_initNetData];
    }
    [self showCloseButton:self.showCloseButton];
    [self showBackButton:!self.showCloseButton];
}

- (void)loadData{


}
#pragma mark CustomeNavigationBarDelegate
-(void)leftBtnMethod
{
    //    NSLog(@"左导航方法");
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnMethod
{
    //    NSLog(@"右导航方法");
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // fix 'nested pop animation can result in corrupted navigation bar'
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    [self.navigationController pushViewController:viewController animated:animated];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//判断字符串是否为空
- (BOOL) isBlankString:(id)string {
    if (!string)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"(null)"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string isEqualToString:@"<null>"])
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [string length]==0)
    {
        return YES;
    }
    if ([string isKindOfClass:[NSString class]] && [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)
    {
        return YES;
    }


    return NO;
}
//沙盒目录
-(NSString *)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
}

//沙盒目录下的存储目录，文件夹名可以随便取
- (NSString *)documentAchiverPath
{
    return [self.documentPath stringByAppendingPathComponent:@"Achiver"];
}

- (NSDictionary *)dataDictionary{
    __block  NSDictionary *dic;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dic = [NSKeyedUnarchiver unarchiveObjectWithFile:[self documentAchiverPath]];
    });
    return dic;
}

- (BOOL)isExistLocalFile{
    // 要检查的文件目录
    NSString *filePath = [self documentAchiverPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return  YES;
    }else {
        return NO;
    }
}

// 删除文件
- (BOOL)deleteFileWithPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSuccess = [fileManager removeItemAtPath:[self documentAchiverPath] error:nil];
    return isSuccess;
}

- (void)saveFileTolocalWithLocalPath:(NSString *)localPath andDataDic:(NSDictionary *)dic{
    if (!dic) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSKeyedArchiver archiveRootObject:dic toFile:[self documentAchiverPath]];
    });
}
//判断是否服务器返回的数据为空
- (BOOL)dx_isNullOrNilWithObject:(id)object
{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            return YES;
        } else {
            return NO;
        }
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if ([object isEqualToNumber:@0]) {
            return YES;
        } else {
            return NO;
        }
    }

    return NO;
}


- (UIViewController *)theTopviewControler{
    //获取根控制器
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;

    UIViewController *parent = rootVC;
    //遍历 如果是presentViewController
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }

    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }

    return rootVC;
}

- (NSString *)handleString:(id)string
{
    NSString *newStr = [NSString stringWithFormat:@"%@",string];
    NSString *backstring;
    if ([self isBlankString:newStr]) {
        backstring = @"";
    }else{
        backstring = newStr;
    }
    return backstring;

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
