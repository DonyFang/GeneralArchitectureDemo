//
//  UserPreferenceManager.m
//  Replenishment
//
//  Created by 方冬冬 on 2017/8/31.
//  Copyright © 2017年 ruwang. All rights reserved.
//

#import "UserPreferenceManager.h"

@implementation UserPreferenceManager

/**
 返回单利对象
 @return instance
 */
+ (instancetype)defaultManager {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 保存用户密码
 @param passWord 用户密码
 */
- (void)saveUserLoginPassWord:(NSString *)passWord{
    if (!passWord) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];

        [standardDefaults setObject:passWord forKey:@"passWord"];
        [standardDefaults synchronize];
    
}

/**
 获取用户登录密码
 @return 用户登录密码
 */
- (NSString *)getUserLoginPassWord{
    NSString *userLoginPassWord = [[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"];
    if (userLoginPassWord == nil) {
        return @"";
    }
    return userLoginPassWord;
}


/**
 保存用户的登陆账号
 
 @param account 用户的登陆账号
 */
- (void)saveUserLoginAccount:(NSString *)account{
    if (!account) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:account forKey:@"account"];
    [standardDefaults synchronize];
}


/**
 获取用户的登陆账号
 
 @return 用户的登陆账号
 */
- (NSString *)getUserLoginAccount{
    NSString *userLoginAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"account"];
    if (userLoginAccount == nil) {
        return @"";
    }
    return userLoginAccount;
}
/**
 删除用户的偏好信息根据对应的key值
 
 @param infoKey  infoKey
 */

- (void)removeUserAccountInfo:(NSString *)infoKey{
    if (!infoKey) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:infoKey];
    [standardDefaults synchronize];
}

- (void)saveUserLoginStatues:(NSString *)loginStatues{
    if (!loginStatues) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:loginStatues forKey:@"loginStatues"];
    [standardDefaults synchronize];

}
/**
 获取用户的登录状态

 @return 用户的登录状态
 */
- (NSString *)getUserLoginStatues{
    NSString *userLoginAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginStatues"];
    if (userLoginAccount == nil) {
        return @"";
    }
    return userLoginAccount;
}


/**
 删除用户的登录状态
 */
- (void)removeUserLoginStatues{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:@"loginStatues"];
    [standardDefaults synchronize];
}

/**
 保存用户登录名
 */

- (void)saveUserName:(NSString *)userName{
    
    if (!userName) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:userName forKey:@"userName"];
    [standardDefaults synchronize];

}

/**
 获取用户登录名

 @return getUserName
 */
- (NSString *)getUserName{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if (userName == nil) {
        return @"";
    }
    return userName;
}

//保存用户的姓名
- (void)saveName:(NSString *)name{
    if (!name) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults setObject:name forKey:@"Name"];
    [standardDefaults synchronize];

}
//获取用户名
- (NSString *)getName{
    NSString *Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"Name"];
    if (Name == nil) {
        return @"";
    }
    return Name;
}


/**
 保存用户头像
 */
- (void)saveUserPhotoName:(NSString *)photoName{
    if ([self isBlankString: photoName]) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setObject:photoName forKey:@"photoName"];
        [standardDefaults synchronize];
}

/**
 获取用户头像
 @return 用户头像
 */
- (NSString *)getUserPhotoName{
    NSString *photoName = [[NSUserDefaults standardUserDefaults] objectForKey:@"photoName"];
    if (photoName == nil) {
        return @"";
    }
    return photoName;
}

/**
 保存单位代码
 */
- (void)saveDepartmentCode:(NSString *)departmentCode{
    if (!departmentCode) {
        return;
    }
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        [standardDefaults setObject:departmentCode forKey:@"departmentCode"];
        [standardDefaults synchronize];

}
/**
 获取单位代码

 @return DepartmentCode
 */

/**
 获取单位代码

 @return DepartmentCode
 */
- (NSString *)getDepartmentCode{
    NSString *departmentCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"departmentCode"];
    if (departmentCode == nil) {
        return @"";
    }      
    return departmentCode;
}
/**
 纪录离线按钮的状态
 */
- (void)saveOnLineBtnStatues:(NSString *)isOnLine{
    if (!isOnLine) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:isOnLine forKey:@"isOnLine"];
    [standardDefaults synchronize];

}
//获取离线按钮的状态
- (NSString *)getOnlineBtnStatues{
    NSString *getOnlineBtnStatues = [[NSUserDefaults standardUserDefaults] objectForKey:@"isOnLine"];
    if (getOnlineBtnStatues == nil) {
        return @"";
    }
    return getOnlineBtnStatues;
}
/**

 存储登录时候 返回的地址层级
 @param levelCount levelCount
 */
- (void)saveAddressLevelCount:(NSString *)levelCount{
    if (!levelCount) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:levelCount forKey:@"levelCount"];
    [standardDefaults synchronize];

}


/**
 返回的地址层级
 */
- (NSString *)getAddressLevelCount{
    NSString *getAddressLevelCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"levelCount"];
    if (getAddressLevelCount == nil) {
        return @"";
    }
    return getAddressLevelCount;
}

/**

 保存用户ID
 @param userID userID
 */
- (void)saveUserID:(NSString *)userID{
    if (!userID) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:userID forKey:@"userID"];
    [standardDefaults synchronize];



}


/**
 返回用户ID
 */
- (NSString *)getUSerID{
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    if (userID == nil) {
        return @"";
    }
    return userID;
}

//保存电话号码
- (void)saveUserTelNum:(NSString *)telNum{

    if ([self isBlankString:telNum]) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:telNum forKey:@"telNum"];
    [standardDefaults synchronize];


}
//获取电话号码
- (NSString *)getUserTel{
    NSString *telNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"telNum"];
    if (telNum == nil) {
        return @"";
    }
    return telNum;
}
//保存供电单位名称
- (void)saveOrgName:(NSString *)orgName{
    if (!orgName) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:orgName forKey:@"orgName"];
    [standardDefaults synchronize];

}

//获取供电单位名称
- (NSString *)getOrgName{
    NSString *orgName = [[NSUserDefaults standardUserDefaults] objectForKey:@"orgName"];
    if (orgName == nil) {
        return @"";
    }
    return orgName;
}
//保存部门名称
- (void)saveDepartment_name:(NSString *)Department_name{
    if (!Department_name) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:Department_name forKey:@"Department_name"];
    [standardDefaults synchronize];

}

//获取部门名称
- (NSString *)getDepartment_name{
    NSString *department_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"Department_name"];
    if (department_name == nil) {
        return @"";
    }
    return department_name;
}


//保存用户新装申请编号
- (void)saveUSerNewInstallApplyNo:(NSString *)appNo{
    if (!appNo) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:appNo forKey:@"appNo_Num"];
    [standardDefaults synchronize];

}

//获取用户新装申请编号
- (NSString *)getUSerNewInstallNO{
    NSString *appNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"appNo_Num"];
    if (appNo == nil) {
        return @"";
    }
    return appNo;
}

/**
 删除所有保存的信息
 */
- (void)removeAllSaveInfo{
    NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [defatluts dictionaryRepresentation];
    for(NSString *key in [dictionary allKeys]){
        [defatluts removeObjectForKey:key];
        [defatluts synchronize];
    }
}

/**
 保存用户的st号
 @param st st
 */
- (void)saveUserStString:(NSString *)st
{
    if (!st) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:st forKey:@"ST"];
    [standardDefaults synchronize];
}
//获取用户的st
- (NSString *)getUserStstring
{
    NSString *ST = [[NSUserDefaults standardUserDefaults] objectForKey:@"ST"];
    if (ST == nil) {
        return @"";
    }
    return ST;

}
//删除ST
- (void)removeStInfo
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults removeObjectForKey:@"ST"];
    [standardDefaults synchronize];
}

//保存用户的流水号
- (void)saveUserSerialNum:(NSString *)serialNum{
    if (!serialNum) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:serialNum forKey:@"serialNum"];
    [standardDefaults synchronize];
}
//获取用户的流水号
- (NSString *)getUserSerialNum{
    NSString *serialNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"serialNum"];
    if (serialNum == nil) {
        return @"";
    }
    return serialNum;
}
//删除流水号
- (void)removeUserSerialNum
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults removeObjectForKey:@"serialNum"];
    [standardDefaults synchronize];
}

//保存AT
- (void)saveUserATString:(NSString *)atStr{
    if (!atStr) {
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:atStr forKey:@"AT"];
    [standardDefaults synchronize];

}
//获取AT
- (NSString *)getAT{
    NSString *AT = [[NSUserDefaults standardUserDefaults] objectForKey:@"AT"];
    if (AT == nil) {
        return @"";
    }
    return AT;
}
//删除AT
- (void)removeATInfo
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults removeObjectForKey:@"AT"];
    [standardDefaults synchronize];
}
//保存盐
- (void)saveSaltString:(NSString *)saltStr{
    if (!saltStr){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:saltStr forKey:@"salt"];
    [standardDefaults synchronize];
}
//获取盐
- (NSString *)getSaltStr{
    NSString *salt = [[NSUserDefaults standardUserDefaults] objectForKey:@"salt"];
    if (salt == nil) {
        return @"";
    }
    return salt;
}
//删除盐
- (void)removeSaltInfo
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults removeObjectForKey:@"salt"];
    [standardDefaults synchronize];
}

//保存权限列表
- (void)saveResourcesList:(NSArray *)resourcesList{
    if ( resourcesList.count > 0) {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:resourcesList forKey:@"resourcesList"];
    }
}

//获取权限列表
- (NSArray *)getResourcesList{
    NSArray *resourcesList = [[NSUserDefaults standardUserDefaults] objectForKey:@"resourcesList"];
    if (resourcesList.count > 0) {
        return resourcesList;
    }
    return @[];
}
//删除资源列表
- (void)removeResourcesList
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults removeObjectForKey:@"resourcesList"];
    [standardDefaults synchronize];
}

//保存设备的UUID
- (void)saveUUIDString:(NSString *)uuidStr{
    if (!uuidStr){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:uuidStr forKey:@"UUID"];
    [standardDefaults synchronize];
}
//获取UUIDstring
- (NSString *)getUUIDString{
    NSString *UUIDStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    if (UUIDStr == nil) {
        return @"";
    }
    return UUIDStr;
}

//保存email
- (void)saveEmail:(NSString *)email{
    if (!email){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:email forKey:@"email"];
    [standardDefaults synchronize];

}
//获取email
- (NSString *)getEmailStr{
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    if (email == nil) {
        return @"";
    }
    return email;
}

//保存用户默认账户
- (void)saveUserDefaultAccount:(NSString *)defaultAccount{
    if (!defaultAccount){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:defaultAccount forKey:@"defaultAccount"];
    [standardDefaults synchronize];
}
//获取用户默认账户
- (NSString *)getDefaultAccount{
    NSString *defaultAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"defaultAccount"];
    if (defaultAccount == nil) {
        return @"";
    }
    return defaultAccount;
}
- (void)removeUserDefaultAccount{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    [standardDefaults removeObjectForKey:@"defaultAccount"];
    [standardDefaults synchronize];
}
//保存用电地址
- (void)saveUserElecAddress:(NSString *)electAdd{
    if (!electAdd){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:electAdd forKey:@"electAdd"];
    [standardDefaults synchronize];
}
//获取用电地址
- (NSString *)getEleAddress{
    NSString *electAdd = [[NSUserDefaults standardUserDefaults] objectForKey:@"electAdd"];
    if (electAdd == nil) {
        return @"";
    }
    return electAdd;
}

//账户金额的单位
- (void)saveAccountMoneyCurrency:(NSString *)MoneyCurrency{
    if (!MoneyCurrency){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:MoneyCurrency forKey:@"MoneyCurrency"];
    [standardDefaults synchronize];

}
//获取金额币种
- (NSString *)getMoneyCurrency{
    NSString *MoneyCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"MoneyCurrency"];
    if (MoneyCurrency == nil) {
        return @"";
    }
    return MoneyCurrency;
}

//保存用户信用等级
- (void)saveUserCreditRatingWith:(NSString *)credit{
    if (!credit){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:credit forKey:@"credit"];
    [standardDefaults synchronize];
}
//获取用户信用等级
- (NSString *)getCreditRating{
    NSString *credit = [[NSUserDefaults standardUserDefaults] objectForKey:@"credit"];
    if (credit == nil) {
        return @"";
    }
    return credit;
}

//保存用户类型
- (void)saveUserType:(NSString *)userType{
    if (!userType){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:userType forKey:@"userType"];
    [standardDefaults synchronize];

}
//获取用户类型
- (NSString *)getUserType{
    NSString *userType = [[NSUserDefaults standardUserDefaults] objectForKey:@"userType"];
    if (userType == nil) {
        return @"";
    }
    return userType;
}

//保存付费模式
- (void)saveArrearsMode:(NSString *)ArrearsMode{
    if (!ArrearsMode){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:ArrearsMode forKey:@"ArrearsMode"];
    [standardDefaults synchronize];


}
//获取付费模式
- (NSString *)getArrearsMode{
    NSString *ArrearsMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"ArrearsMode"];
    if (ArrearsMode == nil) {
        return @"";
    }
    return ArrearsMode;

}
//保存欠费金额
- (void)saveArrearsNum:(NSString *)ArrearsNum{
    if (!ArrearsNum){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:ArrearsNum forKey:@"ArrearsNum"];
    [standardDefaults synchronize];
}
//获取付费金额
- (NSString *)getArrearsNum{
    NSString *getArrearsNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"ArrearsNum"];
    if (getArrearsNum == nil) {
        return @"";
    }
    return getArrearsNum;
}

//保存登录返回的条形码正则校验规则
- (void)saveBarCodeRule:(NSString *)barcodeRule{
    if ([self isBlankString:barcodeRule]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:barcodeRule forKey:@"barcodeRule"];
    [standardDefaults synchronize];
}
- (NSString *)getBarCodeRule{
    NSString *barcodeRule = [[NSUserDefaults standardUserDefaults] objectForKey:@"barcodeRule"];
    if ([self isBlankString:barcodeRule]) {
        return @"";
    }
    return barcodeRule;
}
//保存登录返回的邮箱正则校验规则
- (void)saveEmailRule:(NSString *)emailRule{
    if ([self isBlankString:emailRule]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:emailRule forKey:@"emailRule"];
    [standardDefaults synchronize];
}
- (NSString *)getEmailRule{
    NSString *emailRule = [[NSUserDefaults standardUserDefaults] objectForKey:@"emailRule"];
    if ([self isBlankString:emailRule]) {
        return @"";
    }
    return emailRule;
}
//保存登录返回的手机号码正则校验规则
- (void)saveTelRule:(NSString *)telRule{
    if ([self isBlankString:telRule]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:telRule forKey:@"telRule"];
    [standardDefaults synchronize];
}
- (NSString *)getTelRule{
    NSString *telRule = [[NSUserDefaults standardUserDefaults] objectForKey:@"telRule"];
    if ([self isBlankString:telRule]) {
        return @"";
    }
    return telRule;
}

//保存地址校验规则bug
- (void)saveAddressRule:(NSString *)addRule{
    if ([self isBlankString:addRule]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:addRule forKey:@"addRule"];
    [standardDefaults synchronize];
}
//获取地址校验规则bug
- (NSString *)getAddRule{
    NSString *addRule = [[NSUserDefaults standardUserDefaults] objectForKey:@"addRule"];
    if ([self isBlankString:addRule]) {
        return @"";
    }
    return addRule;
}

//保存图片上传的路径
- (void)savePicUploadPath:(NSString *)picPath{
    if ([self isBlankString:picPath]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:picPath forKey:@"picPath"];
    [standardDefaults synchronize];

}
- (NSString *)getPicPath{
    NSString *picPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"picPath"];
    if ([self isBlankString:picPath]) {
        return @"";
    }
    return picPath;
}

//保存APP头像上传的路径
- (void)saveAppLogoUploadPath:(NSString *)logoPath{
    if ([self isBlankString:logoPath]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:logoPath forKey:@"logoPath"];
    [standardDefaults synchronize];


}
//获取APP头像上传的路径
- (NSString *)getAppLogo{
    NSString *logoPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"logoPath"];
    if ([self isBlankString:logoPath]) {
        return @"";
    }
    return logoPath;
}

- (void)saveLon:(NSString *)lon{
    if ([self isBlankString:lon]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:lon forKey:@"lon"];
    [standardDefaults synchronize];
}
- (NSString *)getLon{
    NSString *lon = [[NSUserDefaults standardUserDefaults] objectForKey:@"lon"];
    if ([self isBlankString:lon]) {
        return @"";
    }
    return lon;
}
- (void)saveLat:(NSString *)lat{
    if ([self isBlankString:lat]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:lat forKey:@"lat"];
    [standardDefaults synchronize];

}
- (NSString *)getLat{
    NSString *lat = [[NSUserDefaults standardUserDefaults] objectForKey:@"lat"];
    if ([self isBlankString:lat]) {
        return @"";
    }
    return lat;
}
//保存用户取消更新的操作
- (void)saveUserCancelOperation:(NSString *)cancel{
    if ([self isBlankString:cancel]){
        return;
    }
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    //目的是看看对应的这个健是否已经设置过默认值  如果设置过就不在设置值
    [standardDefaults setObject:cancel forKey:@"cancel"];
    [standardDefaults synchronize];

}
//获取用户取消更新的操作
- (NSString *)getUserCancel{
    NSString *cancel = [[NSUserDefaults standardUserDefaults] objectForKey:@"cancel"];
    if ([self isBlankString:cancel]) {
        return @"";
    }
    return cancel;
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
@end
