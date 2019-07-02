//
//  UserPreferenceManager.h
//  Replenishment
//
//  Created by 方冬冬 on 2017/8/31.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPreferenceManager : NSObject

/**
 创建单利

 @return 返回一个单利对象
 */
+ (instancetype)defaultManager;


/**
 保存用户密码

 @param passWord 用户密码
 */
- (void)saveUserLoginPassWord:(NSString *)passWord;


/**
 获取用户登录密码

 @return 用户登录密码
 */
- (NSString *)getUserLoginPassWord;


/**
 保存用户的登陆账号

 @param account 用户的登陆账号
 */
- (void)saveUserLoginAccount:(NSString *)account;


/**
 获取用户的登陆账号
 @return 用户的登陆账号
 */
- (NSString *)getUserLoginAccount;


/**
 删除用户的偏好信息根据对应的key值
 @param infoKey  infoKey
 */
- (void)removeUserAccountInfo:(NSString *)infoKey;



/**
 保存用户的登陆状态
 @param loginStatues 用户的登陆登录状态
 */
- (void)saveUserLoginStatues:(NSString *)loginStatues;


/**
 获取用户的登录状态
 @return 用户的登录状态
 */
- (NSString *)getUserLoginStatues;


/**
 删除用户的登录状态
 */
- (void)removeUserLoginStatues;


/**
 保存用户登录名
 */

- (void)saveUserName:(NSString *)userName;

//

/**
 获取用户登录名
 @return getUserName
 */
- (NSString *)getUserName;

//保存用户的姓名
- (void)saveName:(NSString *)name;
//获取用户名
- (NSString *)getName;

/**
 保存用户头像
 */
- (void)saveUserPhotoName:(NSString *)photoName;

/**
 获取用户头像
 @return 用户头像
 */
- (NSString *)getUserPhotoName;

/**
 保存单位代码
 */
- (void)saveDepartmentCode:(NSString *)departmentCode;

/**
 获取单位代码

 @return DepartmentCode
 */
- (NSString *)getDepartmentCode;



/**
 纪录离线按钮的状态
 */
- (void)saveOnLineBtnStatues:(NSString *)isOnLine;
//获取离线按钮的状态
- (NSString *)getOnlineBtnStatues;

/**

 存储登录时候 返回的地址层级
 @param levelCount levelCount
 */
- (void)saveAddressLevelCount:(NSString *)levelCount;


/**
 返回的地址层级
 */
- (NSString *)getAddressLevelCount;

/**

 保存用户ID
 @param userID userID
 */
- (void)saveUserID:(NSString *)userID;


/**
 返回用户ID
 */
- (NSString *)getUSerID;

//保存电话号码
- (void)saveUserTelNum:(NSString *)telNum;

//获取电话号码
- (NSString *)getUserTel;

//保存供电单位名称
- (void)saveOrgName:(NSString *)orgName;

//获取供电单位名称
- (NSString *)getOrgName;

//保存部门名称
- (void)saveDepartment_name:(NSString *)Department_name;

//获取部门名称
- (NSString *)getDepartment_name;

/**
 删除所有保存的信息
 */
- (void)removeAllSaveInfo;

//保存用户新装申请编号
- (void)saveUSerNewInstallApplyNo:(NSString *)appNo;

//获取用户新装申请编号
- (NSString *)getUSerNewInstallNO;

/**
 保存用户的st号
 */
- (void)saveUserStString:(NSString *)st;
//获取用户的st
- (NSString *)getUserStstring;

//删除ST
- (void)removeStInfo;


//保存用户的流水号
- (void)saveUserSerialNum:(NSString *)serialNum;
//获取用户的流水号
- (NSString *)getUserSerialNum;

//删除流水号
- (void)removeUserSerialNum;

//保存AT
- (void)saveUserATString:(NSString *)atStr;
//获取AT
- (NSString *)getAT;

//删除AT
- (void)removeATInfo;

//保存盐
- (void)saveSaltString:(NSString *)saltStr;
//获取盐
- (NSString *)getSaltStr;

//删除盐
- (void)removeSaltInfo;

//保存权限列表
- (void)saveResourcesList:(NSArray *)resourcesList;
//获取权限列表
- (NSArray *)getResourcesList;
//删除资源列表
- (void)removeResourcesList;

//保存设备的UUID
- (void)saveUUIDString:(NSString *)uuidStr;
//获取UUIDstring
- (NSString *)getUUIDString;

//保存email
- (void)saveEmail:(NSString *)email;
//获取email
- (NSString *)getEmailStr;

//保存用户默认账户
- (void)saveUserDefaultAccount:(NSString *)defaultAccount;
//获取用户默认账户
- (NSString *)getDefaultAccount;
//删除用户默认账户

- (void)removeUserDefaultAccount;
//账户金额的单位
- (void)saveAccountMoneyCurrency:(NSString *)MoneyCurrency;
//获取金额币种
- (NSString *)getMoneyCurrency;

//保存用户信用等级
- (void)saveUserCreditRatingWith:(NSString *)credit;
//获取用户信用等级
- (NSString *)getCreditRating;

//保存用户类型
- (void)saveUserType:(NSString *)userType;
//获取用户类型
- (NSString *)getUserType;

//保存付费模式
- (void)saveArrearsMode:(NSString *)ArrearsMode;
//获取付费模式
- (NSString *)getArrearsMode;
//保存欠费金额
- (void)saveArrearsNum:(NSString *)ArrearsNum;
//获取付费金额
- (NSString *)getArrearsNum;

//保存用电地址
- (void)saveUserElecAddress:(NSString *)electAdd;
//获取用电地址
- (NSString *)getEleAddress;

//XYDJ = "<null>";
//XYDJNAME = "<null>";
//保存登录返回的条形码正则校验规则
- (void)saveBarCodeRule:(NSString *)barcodeRule;
- (NSString *)getBarCodeRule;
//保存登录返回的邮箱正则校验规则
- (void)saveEmailRule:(NSString *)emailRule;
- (NSString *)getEmailRule;
//保存登录返回的手机号码正则校验规则
- (void)saveTelRule:(NSString *)telRule;
- (NSString *)getTelRule;
//保存地址校验规则bug
- (void)saveAddressRule:(NSString *)addRule;
//获取地址校验规则bug
- (NSString *)getAddRule;
//保存图片上传的路径
- (void)savePicUploadPath:(NSString *)picPath;
- (NSString *)getPicPath;

//保存APP头像上传的路径
- (void)saveAppLogoUploadPath:(NSString *)logoPath;
//获取APP头像上传的路径
- (NSString *)getAppLogo;

//保存当前的经纬度
- (void)saveLon:(NSString *)lon;
- (NSString *)getLon;
- (void)saveLat:(NSString *)lat;
- (NSString *)getLat;

//保存用户取消更新的操作
- (void)saveUserCancelOperation:(NSString *)cancel;
//获取用户取消更新的操作
- (NSString *)getUserCancel;


@end
