//
//  CYChart.m - 绘图模块
//  CYChartView
//
//  Created by centrin on 15-4-25.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import "CYChartView.h"
#import "CYPoint.h"
#import "CYPointButton.h"

#define ZERO_POINT_MARGIN 10
#define AXIS_HEIGHT_MARGIN 30
#define AXIS_WIDTH_MARGIN 50

#define CHART_TYPE_BAR @"bar"
#define CHART_TYPE_LINE @"line"

@interface CYChartView()
{
    CYPoint* _zeroPoint; // 坐标原点
    double _yAxisHeight; // Y轴高度
    double _xAxisWidth; // X轴宽度
    
    NSInteger _yIntervalCount; // y轴刻度数量
    double _yIntervalLength; // y轴刻度区间高度
    NSInteger _yTickMarkLength; // y轴刻度的线条宽度
    
    NSInteger _yDescLabelWidth; // y轴刻度文字宽度
    
    NSInteger _xIntervalCount; // x轴刻度数量
    NSInteger _xTickMarkLength; // x轴刻度的线条宽度
    BOOL _isShowXTickMark; // 是否显示x轴刻度
    
    NSInteger _xDescLabelWidth; // x轴刻度文字宽度
    
    double _yNumberPixelRate; // 数值像素比
    double _xNumberPixelRate;
    
    NSInteger _maxPointCount; // 最大点数
    
    CAShapeLayer* _promptLayer; // 提示绘图层
    UIView* _promptView; // 提示层
    
    UILabel* _yAxisUnitLabel; // y轴单位标签
    UILabel* _xAxisUnitLabel; // x轴单位标签
    
    NSInteger _chartGroupCount;
    
    NSMutableArray* _graphAttributeAry; // 图形属性数组
}

@end

@implementation CYChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // 默认坐标原点位置
        _zeroPoint = [[CYPoint alloc] initWithX:[NSDecimalNumber numberWithInteger:ZERO_POINT_MARGIN]
                                           andY:[NSDecimalNumber numberWithFloat:(frame.size.height - ZERO_POINT_MARGIN)]];
        _yAxisHeight = frame.size.height - AXIS_HEIGHT_MARGIN - ZERO_POINT_MARGIN;
        _xAxisWidth = frame.size.width - AXIS_WIDTH_MARGIN - ZERO_POINT_MARGIN;
        _yTickMarkLength = 5;
        _xTickMarkLength = 5;
        _yIntervalCount = 5;
        _xIntervalCount = 5;
        _yIntervalLength = (double)_yAxisHeight/(double)_yIntervalCount;
        _xDescLabelWidth = 30;
        
        _needReferenceLine = YES;
        _isReferLine = YES;
        _isShowXTickMark = NO;
        
        // 注册移除提示层的事件
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeprompt)];
        tapGes.numberOfTapsRequired = 1; // 轻击次数
        tapGes.numberOfTouchesRequired = 1; // 手指数
        tapGes.delegate = self;
        [self addGestureRecognizer:tapGes];
        
    }
    
    return self;
}

/**
 *  清空原有视图的子视图和画布
 */
- (void)clearViewAndLayer
{
    NSArray* subViewsAry = self.subviews;
    for (NSInteger i=0,len=[subViewsAry count]; i<len; i++) {
        UIView* subView = (UIView*)[subViewsAry objectAtIndex:i];
        [subView removeFromSuperview];
    }
    
    [self.layer setSublayers:nil];
    
    _promptLayer = nil;
    _promptView = nil;
}

/**
 *  绘制图形
 */
- (void)drawChartLayer{
    
    // 为避免绘图叠加，移除原有画布
    [self clearViewAndLayer];
    
    // 执行代理方法
    // 1.图形组数
    [self setGroupCount];
    
    // 2.设置每个组的图形点数、Y轴最大小值
    [self setGraphAttribute];
    
    
    // 3.设置坐标轴框架
    
    // 计算每个数值对应多少像素
    if (_yMaxValue == 0) {
        _yMaxValue = 10;
    }
    
    // a.如果是圆柱图，当最大最小值相同时，让最高圆柱占图60%高，因为直接到顶不好看
    // b.如果圆柱最大最小值不相等，则y轴直接取最大值
    if ([_chartType isEqualToString:CHART_TYPE_BAR]){
        
        if (_yMaxValue == _yMinValue) {
            _yNumberPixelRate = (double)_yAxisHeight/(double)(_yMaxValue*1.4);
        }else{
            _yNumberPixelRate = (double)_yAxisHeight/(double)_yMaxValue;
        }
        
    }else{ // c.如果是折线图，都是轴高除以最大值加最小值（即最大值-最小值 + 2*最小值），这样能保证图形居中
        _yNumberPixelRate = (double)_yAxisHeight/(double)(_yMaxValue + _yMinValue);
    }
    
    if (_maxPointCount != 0) {
        _xNumberPixelRate = (double)_xAxisWidth/(double)(_maxPointCount+1); // 预留部分空间好看点
    }else{
        _maxPointCount = 1;
    }
    
    // 4.每个点得位置
    if ([_delegate respondsToSelector:@selector(chartView:pointIndex:chartGroup:)]) {
        if ([_chartType isEqualToString:CHART_TYPE_BAR]) {
            [self drawBarChart];
        }else{
            [self drawPlotsAndLines];
        }
    }
    
    [self drawYaxis:_isReferLine];
    
    if (_needReferenceLine) {
        [self drawReferenceLines];
    }
    
    // 5.坐标轴单位
    [self createUnit];
    
}

/**
 *  设置图形组数
 */
- (void)setGroupCount
{
    _chartGroupCount = 1;
    if ([_delegate respondsToSelector:@selector(numberOfChartGroup)]) {
        _chartGroupCount = [_delegate numberOfChartGroup];
    }
    
    // 图形组数必须大于0
    _chartGroupCount = _chartGroupCount > 0 ? _chartGroupCount : 1;
}

/**
 *  默认属性
 */
- (void)setDefaultAttribute
{
    _yMaxValue = 100;
    _yMinValue = 0;
    _maxPointCount = 0; // 最多的那组图形有多少个点
}

/**
 *  设置各个图形的属性
 */
- (void)setGraphAttribute
{
    if (![_delegate respondsToSelector:@selector(chartView:graphAttributeForGroup:)]) {
        [self setDefaultAttribute];
        
        return;
    }
    
    _graphAttributeAry = [[NSMutableArray alloc] initWithCapacity:_chartGroupCount];
    
    for (int i=0; i<_chartGroupCount; i++) {
        CYGraphAttribute* grapAttri = [_delegate chartView:self graphAttributeForGroup:i];
        [_graphAttributeAry addObject:grapAttri];
        
        if (i == 0) {
            _maxPointCount = grapAttri.pointsCount;
            _yMaxValue = grapAttri.maxValue;
            _yMinValue = grapAttri.minValue;
            
            continue;
        }
        
        // 最多点的一组图形有多少个点
        if (grapAttri.pointsCount > _maxPointCount) {
            _maxPointCount = grapAttri.pointsCount;
        }
        
        // y轴最大值
        if (grapAttri.maxValue > _yMaxValue) {
            _yMaxValue = grapAttri.maxValue;
        }
        
        // 最小值
        if (grapAttri.minValue > _yMinValue) {
            _yMinValue = grapAttri.minValue;
        }
        
    }
}

/**
 *  画Y轴
 *
 *  @param isReferLine 是否为参考线样式
 */
- (void)drawYaxis:(BOOL)isReferLine{
    
    // 画Y轴线条
    CAShapeLayer *linesLayer = [CAShapeLayer layer];
    linesLayer.frame = self.bounds;
    linesLayer.fillColor = [UIColor clearColor].CGColor;
    linesLayer.backgroundColor = [UIColor clearColor].CGColor;
    linesLayer.strokeColor = [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4].CGColor;
    linesLayer.lineWidth = 1;
    
    CGMutablePathRef linesPath = CGPathCreateMutable();
    
    if (!isReferLine) { // 非参考线样式，需要画y轴竖线
        CGPathMoveToPoint(linesPath, NULL, [_zeroPoint.x integerValue], [_zeroPoint.y integerValue]);
        CGPathAddLineToPoint(linesPath, NULL, [_zeroPoint.x integerValue], 10);
    }else{ // 设置为虚线，加大透明度
        linesLayer.strokeColor = [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.1].CGColor;
        [linesLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:2],nil]];
    }
    
    
    // 如果单元格数量设置过多，重新调整并减去头尾数量
    if (_yIntervalCount*_yIntervalLength > _yAxisHeight) {
        _yIntervalCount = _yAxisHeight/_yIntervalLength - 2;
    }
    
    // 画Y轴刻度
    for(NSInteger i = 0; i <= _yIntervalCount; i++)
    {
        // 创建Y轴刻度描述文字
        UILabel* ylabel = [[UILabel alloc] initWithFrame:CGRectMake([_zeroPoint.x integerValue] - 30, [_zeroPoint.y integerValue] - _yIntervalLength*i - _yIntervalLength/2, 30, 18)];
        ylabel.backgroundColor = [UIColor clearColor];
        ylabel.font = [UIFont fontWithName:@"Helvetica" size:9];
        [ylabel setTextColor:[UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]];
        NSInteger tempInt = (int)ceil((double)i*_yIntervalLength/_yNumberPixelRate);
        
        [ylabel setText:[NSString stringWithFormat:@"%ld", tempInt]];
        [self addSubview:ylabel];
        
        
        // 原点位置减去单元刻度高度，因为这是相对左上角来计算的
        CGPathMoveToPoint(linesPath, NULL,
                          [_zeroPoint.x integerValue], [_zeroPoint.y integerValue] - tempInt*_yNumberPixelRate);
        
        if (!_isReferLine) { // 非参考线样式则为短刻度，否则为长横线
            CGPathAddLineToPoint(linesPath, NULL, [_zeroPoint.x integerValue]+_yTickMarkLength, [_zeroPoint.y integerValue] - tempInt*_yNumberPixelRate);
        }else{
            CGPathAddLineToPoint(linesPath, NULL, _xAxisWidth + AXIS_WIDTH_MARGIN, [_zeroPoint.y integerValue] - tempInt*_yNumberPixelRate);
        }
    }
    
    linesLayer.path = linesPath;
    [self.layer addSublayer:linesLayer];
    
}

/**
 *  绘制点和连接线
 */
- (void)drawPlotsAndLines
{
    // 画X轴线条
    CAShapeLayer *linesLayer = [CAShapeLayer layer];
    linesLayer.frame = self.bounds;
    linesLayer.fillColor = [UIColor clearColor].CGColor;
    linesLayer.backgroundColor = [UIColor clearColor].CGColor;
    linesLayer.strokeColor = [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4].CGColor;
    linesLayer.lineWidth = 2;
    
    CGMutablePathRef linesPath = CGPathCreateMutable();
    CGPathMoveToPoint(linesPath, NULL, [_zeroPoint.x integerValue], [_zeroPoint.y integerValue]);
    CGPathAddLineToPoint(linesPath, NULL, _xAxisWidth + AXIS_WIDTH_MARGIN, [_zeroPoint.y integerValue]);
    
    CYPoint* point = nil;
    double x,y = 0;
    double prePointX = 0;
    
    // 循环每组数据，设置绘制画布属性
    for (int i = 0; i < [_graphAttributeAry count]; i++) {
        
        CYGraphAttribute* graphAttri = (CYGraphAttribute*)[_graphAttributeAry objectAtIndex:i];
        
        // 原点绘制层
        CGMutablePathRef circlePath = CGPathCreateMutable();
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.frame = self.bounds;
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        circleLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        // 给不同图形设置线条和点的颜色，后续优化
        [circleLayer setStrokeColor:graphAttri.graphColor.CGColor];
        
        [circleLayer setLineWidth:graphAttri.pointRadiu];
        
        // 连接线绘制层
        CGMutablePathRef graphPath = CGPathCreateMutable();
        CAShapeLayer *graphLayer = [CAShapeLayer layer];
        graphLayer.frame = self.bounds;
        graphLayer.fillColor = [UIColor clearColor].CGColor;
        graphLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        [graphLayer setStrokeColor:graphAttri.graphColor.CGColor];
        
        [graphLayer setLineWidth:graphAttri.lineSize];
        
        // 背景阴影
        CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.frame = self.bounds;
        backgroundLayer.fillColor = [UIColor whiteColor].CGColor;
        backgroundLayer.backgroundColor = [UIColor clearColor].CGColor;
        [backgroundLayer setStrokeColor:[UIColor clearColor].CGColor];
        [backgroundLayer setLineWidth:2];
        CGMutablePathRef backgroundPath = CGPathCreateMutable();
        
        
        
        // 循环每个点数据，绘制点和连线
        for(int j = 0; j < graphAttri.pointsCount; j++){
            point = [_delegate chartView:self pointIndex:j chartGroup:i]; // 根据代理方法获取传过来的点值
            
            x = [_zeroPoint.x doubleValue] + j * _xNumberPixelRate;
            y = [_zeroPoint.y doubleValue] - [point.yValue doubleValue] * _yNumberPixelRate;
            
            CGPathAddEllipseInRect(circlePath, NULL, CGRectMake(x-1, y-1, 3, 3)); // 绘制点
            
            if (j == 0) {
                CGPathMoveToPoint(graphPath, NULL, x, y);
                CGPathMoveToPoint(backgroundPath, NULL, x, [_zeroPoint.y integerValue]); // 绘制阴影
                CGPathAddLineToPoint(backgroundPath, NULL, x, y);
            }else{
                CGPathAddLineToPoint(graphPath, NULL, x,  y); // 绘制连线
                CGPathAddLineToPoint(backgroundPath, NULL, x, y); // 绘制阴影
            }
            
            if (j == graphAttri.pointsCount-1) {
                CGPathAddLineToPoint(backgroundPath, NULL, x, [_zeroPoint.y integerValue]); // 绘制阴影
            }
            
            
            // 只最多点的那组图形绘制x轴刻度
            NSInteger intervalPointCount = _maxPointCount/_xIntervalCount;
            if (intervalPointCount == 0) {
                intervalPointCount = 1;
            }
            
            if ((_maxPointCount == graphAttri.pointsCount) && j%intervalPointCount == 0
                && (prePointX == 0 || x-prePointX >= _xDescLabelWidth+2)) {
                
                // 创建X轴刻度描述文字
                UILabel* xlabel = [[UILabel alloc] initWithFrame:CGRectZero];
                xlabel.backgroundColor = [UIColor clearColor];
                xlabel.font = [UIFont fontWithName:@"Helvetica" size:9];
                xlabel.numberOfLines = 0;
                xlabel.lineBreakMode = UILineBreakModeWordWrap;
                [xlabel setTextColor:[UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]];
                [xlabel setText:[point.xLabelText stringByReplacingOccurrencesOfString:@" " withString:@"\n"]];
                
                CGSize labelSize = [xlabel sizeThatFits:CGSizeMake(60, 50)];
                xlabel.frame = CGRectMake(x -5, [_zeroPoint.y integerValue] + 10, labelSize.width, 40);
                _xDescLabelWidth = labelSize.width;
                
                [self addSubview:xlabel];
                
                
                if (_isShowXTickMark) {
                    // 原点位置减去单元刻度高度，因为这是相对左上角来计算的
                    CGPathMoveToPoint(linesPath, NULL, x, [_zeroPoint.y integerValue]);
                    
                    CGPathAddLineToPoint(linesPath, NULL, x, [_zeroPoint.y integerValue] - _xTickMarkLength);
                }
                
                prePointX = x; // 记录上一个刻度位置，用于判断间隔
            }
            
            // 设置点击响应事件，动态显示参考线
            CYPointButton* selectBtn = [[CYPointButton alloc] initWithFrame:CGRectMake(x-22, y-22, 44, 44)];
            selectBtn.backgroundColor = [UIColor clearColor];
            [selectBtn setTitle:@"" forState:UIControlStateNormal];
            
            point.x = [NSNumber numberWithDouble:x];
            point.y = [NSNumber numberWithDouble:y];
            [selectBtn setPoint:point];
            
            selectBtn.belongGraphIndex = i;
            selectBtn.belongGraphName = graphAttri.graphName;
            
            [selectBtn addTarget:self action:@selector(showprompt:)
                forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDown|UIControlEventTouchDragEnter];
            
            [self addSubview:selectBtn];
            
            
        } // end inner for
        
        // 绘制所有边界点，然后包围起来填充
        if (_maxPointCount > 0) {
            CGPathCloseSubpath(backgroundPath);
        }
        
        backgroundLayer.path = backgroundPath;
        
        circleLayer.path = circlePath;
        graphLayer.path = graphPath;
        
        //        CGPathRelease(circlePath);
        //        CGPathRelease(graphPath);
        //        CGPathRelease(backgroundPath);
        
        // 设置背景渐变
        [self gradientBackground:backgroundLayer color:graphAttri.graphColor];
        
        [self.layer addSublayer:graphLayer];
        if (_maxPointCount < 30) { // 因为点太多不好看，所以大于30个点的时候默认把小圆点隐藏不显示
            [self.layer addSublayer:circleLayer];
        }else{
            circleLayer = nil;
        }
    } // end outer for
    
    
    
    linesLayer.path = linesPath;
    
    CGPathRelease(linesPath);
    
    [self.layer addSublayer:linesLayer];
    
    
    if (_chartGroupCount > 1) {
        [self drawPatternExplain];
    }
}


/**
 *  画圆柱图
 */
- (void)drawBarChart
{
    NSInteger barWidth = _xAxisWidth/(_maxPointCount*_chartGroupCount*2);
    if (barWidth < 1) {
        barWidth = 1; // 小于1时会导致看不见
    }else if (barWidth > 20){
        barWidth = 20; // 限定圆柱最大宽度
    }
    NSInteger barLeftMarget = 2*barWidth+_yTickMarkLength+2; // 尽量不要与Y轴刻度叠在一起了
    
    // 画X轴线条
    CAShapeLayer *linesLayer = [CAShapeLayer layer];
    linesLayer.frame = self.bounds;
    linesLayer.fillColor = [UIColor clearColor].CGColor;
    linesLayer.backgroundColor = [UIColor clearColor].CGColor;
    linesLayer.strokeColor = [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4].CGColor;
    linesLayer.lineWidth = 1;
    
    CGMutablePathRef linesPath = CGPathCreateMutable();
    CGPathMoveToPoint(linesPath, NULL, [_zeroPoint.x integerValue], [_zeroPoint.y integerValue]);
    CGPathAddLineToPoint(linesPath, NULL, _xAxisWidth + AXIS_WIDTH_MARGIN, [_zeroPoint.y integerValue]);
    
    CYPoint* point = nil;
    double x,y = 0;
    double prePointX = 0;
    
    
    for (int i = 0; i < [_graphAttributeAry count]; i++) {
        
        CYGraphAttribute* graphAttri = (CYGraphAttribute*)[_graphAttributeAry objectAtIndex:i];
        
        // 圆柱图绘制层
        CGMutablePathRef graphPath = CGPathCreateMutable();
        CAShapeLayer *graphLayer = [CAShapeLayer layer];
        graphLayer.frame = self.bounds;
        graphLayer.fillColor = [UIColor clearColor].CGColor;
        graphLayer.backgroundColor = [UIColor clearColor].CGColor;
        [graphLayer setStrokeColor:graphAttri.graphColor.CGColor];
        [graphLayer setLineWidth:barWidth];
        
        for(int j = 0; j < graphAttri.pointsCount; j++){
            point = [_delegate chartView:self pointIndex:j chartGroup:i]; // 根据代理方法获取传过来的点值
            
            x = [_zeroPoint.x doubleValue] + j * _xNumberPixelRate + barWidth*i + barLeftMarget;
            y = [_zeroPoint.y doubleValue] - [point.yValue doubleValue] * _yNumberPixelRate;
            
            CGPathMoveToPoint(graphPath, NULL, x, [_zeroPoint.y integerValue]-1);
            CGPathAddLineToPoint(graphPath, NULL, x,  y); // 绘制连线
            
            // 只最多点的那组图形绘制x轴刻度
            NSInteger intervalPointCount = _maxPointCount/_xIntervalCount;
            if (intervalPointCount == 0) {
                intervalPointCount = 1;
            }
            
            if ((_maxPointCount == graphAttri.pointsCount) && j%intervalPointCount == 0
                && (prePointX == 0 || x-prePointX >= _xDescLabelWidth+2)) {
                
                // 创建X轴刻度描述文字
                UILabel* xlabel = [[UILabel alloc] initWithFrame:CGRectZero];
                xlabel.backgroundColor = [UIColor clearColor];
                xlabel.font = [UIFont fontWithName:@"Helvetica" size:9];
                xlabel.numberOfLines = 0;
                xlabel.lineBreakMode = UILineBreakModeWordWrap;
                [xlabel setTextColor:[UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]];
                [xlabel setText:[point.xLabelText stringByReplacingOccurrencesOfString:@" " withString:@"\n"]];
                
                CGSize labelSize = [xlabel sizeThatFits:CGSizeMake(60, 50)];
                xlabel.frame = CGRectMake(x -5, [_zeroPoint.y integerValue] + 10, labelSize.width, 40);
                _xDescLabelWidth = labelSize.width;
                
                [self addSubview:xlabel];
                
                if (_isShowXTickMark) {
                    // 原点位置减去单元刻度高度，因为这是相对左上角来计算的
                    CGPathMoveToPoint(linesPath, NULL, x, [_zeroPoint.y integerValue]);
                    
                    CGPathAddLineToPoint(linesPath, NULL, x, [_zeroPoint.y integerValue] - _xTickMarkLength);
                }
                
                prePointX = x; // 记录上一个刻度位置，用于判断间隔
            }
            
            
            
            // 设置点击响应事件，动态显示参考线
            CYPointButton* selectBtn = [[CYPointButton alloc] initWithFrame:CGRectMake(x-barWidth/2, y, barWidth, [_zeroPoint.y integerValue] - y)];
            selectBtn.backgroundColor = [UIColor clearColor];
            [selectBtn setTitle:@"" forState:UIControlStateNormal];
            
            point.x = [NSNumber numberWithDouble:x];
            point.y = [NSNumber numberWithDouble:y];
            [selectBtn setPoint:point];
            
            selectBtn.belongGraphIndex = i;
            selectBtn.belongGraphName = graphAttri.graphName;
            
            [selectBtn addTarget:self action:@selector(showprompt:)
                forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDown|UIControlEventTouchDragEnter];
            
            [self addSubview:selectBtn];
        }
        
        graphLayer.path = graphPath;
        [self.layer addSublayer:graphLayer];
    }
    
    linesLayer.path = linesPath;
    [self.layer addSublayer:linesLayer]; // x轴刻度要显示在圆柱图上面，所以在后面才加入
}


/**
 *  绘制参考线
 */
- (void)drawReferenceLines{
    
    if (_maxPointCount < 3 || _yMaxValue == _yMinValue) {
        return;
    }
    
    int labelSize = 50;
    
    CAShapeLayer *referenceLayer = [CAShapeLayer layer];
    referenceLayer.frame = self.bounds;
    referenceLayer.fillColor = [UIColor clearColor].CGColor;
    referenceLayer.backgroundColor = [UIColor clearColor].CGColor;
    referenceLayer.strokeColor = [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4].CGColor;
    referenceLayer.lineWidth = 1;
    [referenceLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:2],nil]];
    
    CGMutablePathRef referencePath = CGPathCreateMutable();
    
    // 最大值
    CGPathMoveToPoint(referencePath, NULL,
                      [_zeroPoint.x integerValue], [_zeroPoint.y integerValue] - _yMaxValue*_yNumberPixelRate);
    
    CGPathAddLineToPoint(referencePath, NULL, AXIS_WIDTH_MARGIN+_xAxisWidth,  [_zeroPoint.y integerValue] - _yMaxValue*_yNumberPixelRate);
    UILabel* maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(AXIS_WIDTH_MARGIN+_xAxisWidth+1, [_zeroPoint.y integerValue] - _yMaxValue*_yNumberPixelRate-labelSize/2, labelSize, labelSize)];
    maxLabel.font = [UIFont fontWithName:@"Helvetica" size:9];
    [maxLabel setTextColor:[UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]];
    maxLabel.backgroundColor = [UIColor clearColor];
    [maxLabel setText:[NSString stringWithFormat:@"max:%ld", _yMaxValue]];
    maxLabel.numberOfLines = 2;
    maxLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self addSubview:maxLabel];
    
    // 最小值
    if (_yMinValue != 0) {
        CGPathMoveToPoint(referencePath, NULL,
                          [_zeroPoint.x integerValue], [_zeroPoint.y integerValue] - _yMinValue*_yNumberPixelRate);
        
        CGPathAddLineToPoint(referencePath, NULL, AXIS_WIDTH_MARGIN+_xAxisWidth,  [_zeroPoint.y integerValue] - _yMinValue*_yNumberPixelRate);
    }
    UILabel* minLabel = [[UILabel alloc] initWithFrame:CGRectMake(AXIS_WIDTH_MARGIN+_xAxisWidth+1, [_zeroPoint.y integerValue] - _yMinValue*_yNumberPixelRate-labelSize/2, labelSize, labelSize)];
    minLabel.font = [UIFont fontWithName:@"Helvetica" size:9];
    [minLabel setTextColor:[UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4]];
    minLabel.backgroundColor = [UIColor clearColor];
    [minLabel setText:[NSString stringWithFormat:@"min:%ld", _yMinValue]];
    minLabel.numberOfLines = 2;
    minLabel.lineBreakMode = UILineBreakModeWordWrap;
    [self addSubview:minLabel];
    
    [referenceLayer setPath:referencePath];
    CGPathRelease(referencePath);
    [[self layer] addSublayer:referenceLayer];
    
}

/**
 *  显示提示层
 *
 *  @param sender 点按钮对象
 */
- (void)showprompt:(id)sender
{
    [self removeprompt];
    
    if (_xAxisUnit == nil) {
        _xAxisUnit = @"X";
    }
    if (_yAxisUnit == nil) {
        _yAxisUnit = @"Y";
    }
    
    // 绘制纵横参考线
    CYPointButton* pointButon = (CYPointButton*)sender;
    CYPoint* point = pointButon.point;
    
    _promptLayer = [CAShapeLayer layer];
    _promptLayer.frame = self.bounds;
    _promptLayer.fillColor = [UIColor clearColor].CGColor;
    _promptLayer.backgroundColor = [UIColor clearColor].CGColor;
    _promptLayer.strokeColor = [UIColor colorWithRed:0.48 green:0.48 blue:0.49 alpha:0.4].CGColor;
    _promptLayer.lineWidth = 1;
    [_promptLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:2],nil]];
    
    CGMutablePathRef promptPath = CGPathCreateMutable();
    
    CGPathMoveToPoint(promptPath, NULL,
                      [_zeroPoint.x integerValue], [point.y doubleValue]);
    
    CGPathAddLineToPoint(promptPath, NULL, AXIS_WIDTH_MARGIN+_xAxisWidth,  [point.y doubleValue]);
    
    CGPathMoveToPoint(promptPath, NULL,
                      [point.x doubleValue], [_zeroPoint.y integerValue]);
    
    CGPathAddLineToPoint(promptPath, NULL, [point.x doubleValue],  AXIS_HEIGHT_MARGIN);
    
    
    _promptLayer.path = promptPath;
    
    [self.layer addSublayer:_promptLayer];
    
    // 显示提示文字
    _promptView = [[UIView alloc] initWithFrame:CGRectZero];
    _promptView.backgroundColor = [UIColor blackColor];
    [_promptView.layer setCornerRadius:5];
    _promptView.alpha = 0.7;
    // x轴数值
    UILabel* xlabel= [[UILabel alloc] initWithFrame:CGRectZero];
    xlabel.backgroundColor = [UIColor clearColor];
    xlabel.font = [UIFont fontWithName:@"Helvetica" size:9];
    xlabel.numberOfLines = 1;
    [xlabel setTextColor:[UIColor whiteColor]];
    [xlabel setText:[NSString stringWithFormat:@"%@：%@", _xAxisUnit, point.xLabelText]];
    
    CGSize xlabelSize = [xlabel sizeThatFits:CGSizeMake(300, 30)];
    xlabel.frame = CGRectMake(15, AXIS_HEIGHT_MARGIN/2, xlabelSize.width, AXIS_HEIGHT_MARGIN/2);
    
    [_promptView addSubview:xlabel];
    
    // y轴数值
    UILabel* ylabel= [[UILabel alloc] initWithFrame:CGRectZero];
    ylabel.backgroundColor = [UIColor clearColor];
    ylabel.font = [UIFont fontWithName:@"Helvetica" size:9];
    ylabel.numberOfLines = 1;
    [ylabel setTextColor:[UIColor whiteColor]];
    
    if (pointButon.belongGraphName != nil && pointButon.belongGraphName.length >0) {
        [ylabel setText:[NSString stringWithFormat:@"%@：%@", pointButon.belongGraphName, point.yLabelText]];
    }else{
        [ylabel setText:[NSString stringWithFormat:@"%@：%@", _yAxisUnit, point.yLabelText]];
    }
    
    CGSize ylabelSize = [ylabel sizeThatFits:CGSizeMake(300, 30)];
    ylabel.frame = CGRectMake(15, 0, ylabelSize.width, AXIS_HEIGHT_MARGIN/2);
    
    [_promptView addSubview:ylabel];
    
    // 重新计算显示层长度
    if (xlabelSize.width > ylabelSize.width) {
        _promptView.frame = CGRectMake(ZERO_POINT_MARGIN, 0, xlabelSize.width+30, AXIS_HEIGHT_MARGIN);
    }else{
        _promptView.frame = CGRectMake(ZERO_POINT_MARGIN, 0, ylabelSize.width+30, AXIS_HEIGHT_MARGIN);
    }
    
    [self addSubview:_promptView];
    
    
}

/**
 *  移除提示层
 */
- (void)removeprompt
{
    if (_promptLayer) {
        [_promptLayer removeFromSuperlayer];
        _promptLayer = nil;
    }
    if (_promptView) {
        [_promptView removeFromSuperview];
        _promptView = nil;
    }
}

/**
 *  添加渐变背景
 *
 *  @param targetLayer 渐变路径约束层
 */
- (void)gradientBackground:(CAShapeLayer*)targetLayer color:(UIColor*)color
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)color.CGColor,
                       (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor,
                       nil];
    
    [gradient setMask:targetLayer]; // 用targetLayer来截取渐变层gradient
    [self.layer addSublayer:gradient];
    //    [self.layer insertSublayer:gradient atIndex:0];
}

/**
 *  绘制右上角图形样式说明
 */
- (void)drawPatternExplain
{
    NSInteger labelWidth = 26;
    NSInteger lineWidth = 15;
    for (int i = 0; i < _chartGroupCount; i++) {
        
        CYGraphAttribute* graphAttri = (CYGraphAttribute*)[_graphAttributeAry objectAtIndex:i];
        
        if (graphAttri == nil || graphAttri.graphName == nil) {
            continue;
        }
        
        UILabel* line = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-(lineWidth+labelWidth+10)*(_chartGroupCount-i)+20, -7.5, lineWidth, 2)];
        line.backgroundColor = graphAttri.graphColor;
        [self addSubview:line];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(line.frame.origin.x+lineWidth, -17, labelWidth, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontWithName:@"Helvetica" size:12];
        label.textAlignment = NSTextAlignmentRight;
        label.text = graphAttri.graphName;
        [self addSubview:label];
    }
}

/**
 *  设置y轴单位
 *
 *  @param yAxisUnit 单位描述
 */
- (void)setYAxisUnit:(NSString *)yAxisUnit
{
    _yAxisUnit = nil;
    _yAxisUnit = yAxisUnit;
    
    _yAxisUnitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _yAxisUnitLabel.backgroundColor = [UIColor clearColor];
    _yAxisUnitLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    _yAxisUnitLabel.textColor = [UIColor blackColor];
    [_yAxisUnitLabel setText:_yAxisUnit];
    
    CGSize contentSize = [_yAxisUnitLabel sizeThatFits:CGSizeMake(1000, 20)];
    _yAxisUnitLabel.frame = CGRectMake(-20, -17, contentSize.width, 20);
    
}

/**
 *  设置x轴单位
 *
 *  @param xAxisUnit 单位描述
 */
- (void)setXAxisUnit:(NSString *)xAxisUnit
{
    _xAxisUnit = nil;
    _xAxisUnit = xAxisUnit;
    
    _xAxisUnitLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _xAxisUnitLabel.backgroundColor = [UIColor clearColor];
    _xAxisUnitLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    _xAxisUnitLabel.textColor = [UIColor blackColor];
    [_xAxisUnitLabel setText:_xAxisUnit];
    
    CGSize contentSize = [_xAxisUnitLabel sizeThatFits:CGSizeMake(1000, 20)];
    _xAxisUnitLabel.frame = CGRectMake(self.frame.size.width-contentSize.width+15, [_zeroPoint.y integerValue]+3, contentSize.width, 20);
}

/**
 *  添加坐标轴单位
 */
- (void)createUnit
{
    if (_yAxisUnitLabel) {
        [self addSubview:_yAxisUnitLabel];
    }
    if (_xAxisUnitLabel) {
        [self addSubview:_xAxisUnitLabel];
    }
}


@end
