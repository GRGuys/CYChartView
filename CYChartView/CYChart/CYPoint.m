//
//  CYPoint.m - 坐标点对象
//  CYChartView
//
//  Created by centrin on 15-4-25.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import "CYPoint.h"

@implementation CYPoint

- (id)initWithX:(NSNumber*)x andY:(NSNumber*)y
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.radius = 2; // 默认半径
        self.backColor = [UIColor blackColor]; // 默认背景色
    }
    return self;
}


@end
