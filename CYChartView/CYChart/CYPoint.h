//
//  CYPoint.h - 坐标点对象
//  CYChartView
//
//  Created by centrin on 15-4-25.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CYPoint : NSObject

@property (nonatomic, retain) NSNumber* x; // x坐标
@property (nonatomic, retain) NSNumber* y; // y坐标

@property (nonatomic, assign) NSInteger radius; // 半径
@property (nonatomic, retain) UIColor* backColor; // 背景颜色

@property (nonatomic, retain) NSString* xValue; // x数值
@property (nonatomic, retain) NSString* yValue; // y数值

@property (nonatomic, retain) NSString* xLabelText; // x描述文字
@property (nonatomic, retain) NSString* yLabelText; // y描述文字


/**
 *  初始化坐标点，默认半径为2，背景色为黑
 *
 *  @param x x坐标
 *  @param y y坐标
 *
 *  @return 坐标对象
 */
- (id)initWithX:(NSNumber*)x andY:(NSNumber*)y;

@end
