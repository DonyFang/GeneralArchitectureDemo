//
//  BaseViewController.h
//  GeneralArchitecture
//
//  Created by 方冬冬 on 2019/4/23.
//  Copyright © 2019年 方冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitProtocol.h"
@interface BaseViewController : UIViewController<InitProtocol>
 //是否显示导航栏按钮
@property (nonatomic, assign) BOOL showCloseButton;
- (BOOL) isBlankString:(id)string;
- (void)loadData;

//沙盒目录
-(NSString *)documentPath;
//沙盒目录下的存储目录，文件夹名可以随便取
- (NSString *)documentAchiverPath;
- (NSDictionary *)dataDictionary;
//检查本地是否含有某个文件
- (BOOL)isExistLocalFile;
// 删除文件
- (BOOL)deleteFileWithPath:(NSString *)filePath;
//保存文件到指定的路径
- (void)saveFileTolocalWithLocalPath:(NSString *)localPath andDataDic:(NSDictionary *)dic;
//判断是否服务器返回的数据为空
- (BOOL)dx_isNullOrNilWithObject:(id)object;

- (UIViewController *)theTopviewControler;
- (NSString *)handleString:(id)string;
@end
