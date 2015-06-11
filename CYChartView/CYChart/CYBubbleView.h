//
//  CYBubbleView.h
//  CYChartView
//
//  Created by centrin on 15-4-30.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYPoint.h"

@class CYBubbleView;

@protocol CYBubbleViewDelegate <NSObject>

/**
 *  是否选中了某个点对象
 *
 *  @param bubbleView 该气泡窗体
 *  @param point      该点对象
 */
- (void)bubbleView:(CYBubbleView*)bubbleView didSelectedPoint:(CYPoint*)point;


@end



@interface CYBubbleView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSNumber* pointX;
@property (nonatomic, retain) NSNumber* pointY;

@property (nonatomic, retain) NSString* showText;

@end
