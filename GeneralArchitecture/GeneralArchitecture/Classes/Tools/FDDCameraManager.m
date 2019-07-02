//
//  FDDCameraManager.m
//  MOffice
//
//  Created by 方冬冬 on 2019/4/29.
//  Copyright © 2019年 ChinaSoft. All rights reserved.
//

#import "FDDCameraManager.h"
@interface FDDCameraManager()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)UIImagePickerController *pickerController;
@end
@implementation FDDCameraManager
+ (instancetype)sharedManager {
    static FDDCameraManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)startPhotoWithOperationType:(OperationType)type
{
    switch (type) {
        case Camera:
            if([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
                _pickerController = [[UIImagePickerController alloc]init];
                _pickerController.delegate = self;
                _pickerController.allowsEditing=YES;
                _pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_pickerController animated:YES completion:nil];
            }
        case PhotoAlbum:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {//此设备是否有相册
                _pickerController = [[UIImagePickerController alloc] init];//创建一个相册界面
                _pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                _pickerController.allowsEditing = YES;//是否允许编辑
                _pickerController.delegate = self;
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_pickerController animated:YES completion:nil];
            }
            break;

        default:
            break;
    }

}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    /// 在这里拿到照片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];//在相册里面选中的图片
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *fileName = [NSString stringWithFormat:@"%@_TP.jpeg",[formatter stringFromDate:[NSDate date]]];
    NSString *departmentCode =   [[UserPreferenceManager defaultManager] getDepartmentCode];
    NSString *imageName = [NSString stringWithFormat:@"%@_%@",departmentCode,fileName];
    [self saveImage:image name:imageName];//把选中的图片存到本地沙盒里面

    //回传照片
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];//用得时候取出来，要和保存的路径保持一致
    UIImage *localImage = [[UIImage alloc] initWithContentsOfFile:path];//通过路径找到保存的那张图片
    if (self.Finishedblock) {
        self.Finishedblock(localImage);
    }

    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
//取消按钮的代理
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
//保存一张图片
- (void)saveImage:(UIImage *)image name:(NSString *)nameString {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:nameString];
    NSLog(@"%@",path);
    NSData *data = UIImageJPEGRepresentation(image, 0.5);//把图片转成二进制数据
    [data writeToFile:path atomically:YES];//把转成的二进制数据存到本地
}

@end
