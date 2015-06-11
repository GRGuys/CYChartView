//
//  CYBubbleView.m
//  CYChartView
//
//  Created by centrin on 15-4-30.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import "CYBubbleView.h"

@implementation CYBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPrompt)];
        ges.numberOfTouchesRequired = 1; // 手指数
        ges.numberOfTapsRequired = 1; // tap次数
        ges.delegate = self;
        
    }
    
    return self;
}

- (void)showPrompt
{
    
}


@end
