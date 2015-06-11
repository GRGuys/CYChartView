//
//  CYChartModel.m
//  CiYunApp
//
//  Created by centrin on 15/6/1.
//  Copyright (c) 2015年 zhaoyuguang. All rights reserved.
//

#import "CYGraphAttribute.h"

@implementation CYGraphAttribute

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setDefaultAttri];
    }
    
    return self;
}

/**
 *  如果用户未对图形设置自定义属性，则默认使用该属性
 */
- (void)setDefaultAttri
{
    _pointsCount = 1;
    _maxValue = 10;
    _minValue = 0;
    
    _graphColor = [UIColor colorWithRed:0.51f green:0.84f blue:0.34f alpha:1.0f];
    _pointRadiu = 3;
    _lineSize = 1;
}

- (void)setGraphColor:(UIColor *)graphColor
{
    _graphColor = nil;
    _graphColor = graphColor;
}

@end
