//
//  EGUToast.m
//  
//
//  Created by danny on 15/9/8.
//  Copyright (c) 2015年 danny. All rights reserved.
//

#import "EGUToast.h"
#import <QuartzCore/QuartzCore.h>

#define TOAST_WIDTH 240
#define TOAST_HIEGHT 58
#define DEFAULT_DURATION 2.0f;

@implementation EGUToast{
    NSString* text;
    UIImageView* contentview;
    float duration;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              name:UIDeviceOrientationDidChangeNotification
                                                 object:([UIDevice currentDevice])];
#if !__has_feature(objc_arc)
    [text release];
    [contentview release];
    [super dealloc];
#endif
    
    
}

- (id)initWithText:(NSString*) txt {
    if (self = [super init]) {
        text = [txt copy];
        
        //背景
        contentview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, TOAST_WIDTH, TOAST_HIEGHT)];
//        UIImage *nomalImage = [UIImage imageNamed:@"bg_toast"];
        
        UIImage *nomalImage = [self imageWithColor:[UIColor blackColor] alpha:0.7];
        
        CGFloat hInset = floorf(nomalImage.size.width / 2);
        CGFloat vInset = floorf(nomalImage.size.height / 2);
        
        UIImage *res = [nomalImage resizableImageWithCapInsets:UIEdgeInsetsMake(vInset, hInset, vInset, hInset)];
        
        [contentview setImage:res];
        
        
        //前面的字体
        CGFloat realWidth = TOAST_WIDTH - 72;
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        NSDictionary *attribute = @{NSFontAttributeName: font};
//        CGSize textSize =[text sizeWithFont:font
//                          constrainedToSize:CGSizeMake(realWidth, MAXFLOAT)
//                              lineBreakMode:NSLineBreakByCharWrapping];
        CGSize textSize = [text boundingRectWithSize:CGSizeMake(realWidth, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine |
                           NSStringDrawingUsesLineFragmentOrigin |
                           NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
//        CGSize textSize = [str sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]]
        
        if (textSize.height > 14) {
            
            CGFloat newHeight = 58 + textSize.height - 14;
            [contentview setFrame:CGRectMake(0, 0, TOAST_WIDTH, newHeight)];
            
        }
        UILabel *textLabel = [[UILabel alloc]
                              initWithFrame:CGRectMake( ( realWidth - textSize.width) / 2,  (TOAST_HIEGHT - textSize.height) /2 , textSize.width, textSize.height)];
        textLabel.center = contentview.center;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = font;
        textLabel.text = text;
        textLabel.numberOfLines = 0;
        
        //淡入
        contentview.alpha = 0.0f;
        
        [contentview addSubview:textLabel];
        
        
        duration = DEFAULT_DURATION;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
    }
    
    return self;
}

- (void)deviceOrientationDidChanged:(NSNotification *)notify{
    [self hideAnimation];
}

- (void)dismissToast{
    [contentview removeFromSuperview];
}

- (void)setDuration:(CGFloat) duration_{
    duration = duration_;
}

-(void)showAnimation{
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    contentview.alpha = 1.0f;
    [UIView commitAnimations];
}

-(void)hideAnimation{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissToast)];
    [UIView setAnimationDuration:0.3];
    contentview.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    TRACE(@" window level = %f" , window.windowLevel);
    CGPoint newCenter= window.center;
    
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {

       //contentview.transform = CGAffineTransformMakeRotation(angle);
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        CGFloat roateAngle = 0.0f;
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:{
                roateAngle = M_PI;
                break;
            }
            case UIInterfaceOrientationLandscapeLeft:{
                roateAngle = -M_PI/2.0f;
                break;
            }
            case UIInterfaceOrientationLandscapeRight:{
                roateAngle = M_PI/2.0f;
                break;
            }
                
                
            default:
                break;
        }
        contentview.transform = CGAffineTransformMakeRotation(roateAngle);
        
        //旋转角度 切换xy的值
        CGFloat tp = newCenter.x;
        newCenter.x = newCenter.y;
        newCenter.y = tp;
        
        
    }

    
    contentview.center = newCenter;
    
    [window  addSubview:contentview];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:duration];
}


- (UIImage *)imageWithColor:(UIColor *)color alpha:(CGFloat) alpha{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //设置透明度
    CGContextSetAlpha(context, alpha);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+ (void)makeToast:(NSString *)text andDuration:(float)time{
    
    EGUToast *toast = [[EGUToast alloc] initWithText:text];
    
//    TRACE(@" show toast");
    [toast setDuration:time];
    [toast show];
    
}

+ (void)makeToast:(NSString *)text{
    [EGUToast makeToast:text andDuration:2.0];
}
@end
