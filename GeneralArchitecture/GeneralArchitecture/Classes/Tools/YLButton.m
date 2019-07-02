
//
//  YLButton.m
//  YLButton
//
//  Created by HelloYeah on 2016/11/24.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLButton.h"

@implementation YLButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    if (!CGRectIsEmpty(self.titleRect) && !CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    }
    return [super titleRectForContentRect:contentRect];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    if (!CGRectIsEmpty(self.imageRect) && !CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    }
    return [super imageRectForContentRect:contentRect];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event

{       
    if (self.isEnlarge) {
        CGRect bounds = self.bounds;

        bounds = CGRectInset(bounds, -50,-50);
        
        return CGRectContainsPoint(bounds, point);
    }else{
        CGRect bounds = self.bounds;
        
        bounds = CGRectInset(bounds, 0,0);
        
        return CGRectContainsPoint(bounds, point);

    }
}
@end
