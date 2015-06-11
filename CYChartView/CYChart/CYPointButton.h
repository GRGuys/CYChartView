//
//  CYPointButton.h
//  CYChartView
//
//  Created by centrin on 15-4-30.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYPoint.h"

@interface CYPointButton : UIButton

@property (nonatomic, assign) NSInteger belongGraphIndex; // 所属图形索引
@property (nonatomic, retain) NSString* belongGraphName; // 图形名称

@property (nonatomic, retain) CYPoint* point;

@end
