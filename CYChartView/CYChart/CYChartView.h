//
//  CYChart.h
//  CYChartView
//
//  Created by centrin on 15-4-25.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYPoint.h"
#import "CYGraphAttribute.h"

@class CYChartView;
@protocol CYChartViewDelegate <NSObject>

@optional

/**
 *  设置图表分组数，组数必须大于0
 *
 *  @return 图表组数
 */
- (NSInteger)numberOfChartGroup;

/**
 *  设置图形模型数据
 *
 *  @param chartView 图表对象
 *  @param group     图表的组索引
 *
 *  @return 模型对象
 */
- (CYGraphAttribute*)chartView:(CYChartView*)chartView graphAttributeForGroup:(NSInteger)group;

/**
 *  设置每个点得绘制属性
 *
 *  @param chartView  绘制图表对象
 *  @param pointIndex 第几个点
 *  @param chartGroup 图片的分组，默认为0，处理一个图表多个图形的情况
 *
 *  @return 点对象
 */
- (CYPoint*)chartView:(CYChartView*)chartView pointIndex:(NSInteger)pointIndex chartGroup:(NSInteger)chartGroup;

@end



@interface CYChartView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) NSInteger yMaxValue; // y轴最大值
@property (nonatomic, assign) NSInteger yMinValue; // y轴最小值

@property (nonatomic, retain) NSString* yAxisUnit; // y轴单位
@property (nonatomic, retain) NSString* xAxisUnit; // x轴单位

@property (nonatomic, retain) NSString* chartType; // 图形类型：line折线；bar圆柱
@property (nonatomic, assign) BOOL isReferLine; // y轴是否显示为参考线样式
@property (nonatomic, assign) BOOL needReferenceLine;

@property (nonatomic, assign) id <CYChartViewDelegate> delegate;

- (void)drawChartLayer;

@end