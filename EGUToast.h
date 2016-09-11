//
//  EGUToast.h
//
//
//  Created by danny on 15/9/8.
//  Copyright (c) 2015年 danny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGUToast : NSObject

+ (void)makeToast:(NSString *)text andDuration:(float) time;

+ (void)makeToast:(NSString *)text;
@end
