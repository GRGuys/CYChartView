//
//  ViewController.m
//  CYChartView
//
//  Created by centrin on 15-4-25.
//  Copyright (c) 2015年 centrin. All rights reserved.
//

#import "ViewController.h"
#import "CYChartView.h"

@interface ViewController ()

@property(nonatomic, retain) CYChartView* chartView;
@property(nonatomic, retain) NSMutableDictionary* dic;
@property(nonatomic, retain) NSMutableDictionary* dic1;
@property(nonatomic, retain) NSString* chartType;
@property(nonatomic, retain) UILabel* sliderLabel;
@property(nonatomic, retain) UISlider* slider;
@property(nonatomic, assign) NSInteger totalCount;
@property(nonatomic, assign) NSInteger maxValue;
@property(nonatomic, assign) NSInteger minValue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _totalCount = 0;
    
    // 创建演示用得控制面板
    
    UIView* btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 200)];
    btnView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btnView];
    
    UILabel* swiLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 150, 30)];
    swiLabel.backgroundColor = [UIColor clearColor];
    [swiLabel setText:@"折线图/圆柱图："];
    [swiLabel setTextColor:[UIColor whiteColor]];
    [btnView addSubview:swiLabel];
    UISwitch* swi = [[UISwitch alloc] initWithFrame:CGRectMake(150, 20, 100, 30)];
    [swi addTarget:self action:@selector(switchType:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:swi];
    
    _sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 120, 30)];
    _sliderLabel.backgroundColor = [UIColor clearColor];
    [_sliderLabel setText:[NSString stringWithFormat:@"点数量：%d",_totalCount] ];
    [_sliderLabel setTextColor:[UIColor whiteColor]];
    [btnView addSubview:_sliderLabel];
    
    UIButton* addbtn = [[UIButton alloc] initWithFrame:CGRectMake(280, 50, 40, 40)];
    addbtn.backgroundColor = [UIColor clearColor];
    [addbtn setTitle:@"+" forState:UIControlStateNormal];
    [addbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addbtn addTarget:self action:@selector(addCount) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:addbtn];
    
    UIButton* removebtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 40, 40)];
    removebtn.backgroundColor = [UIColor clearColor];
    [removebtn setTitle:@"-" forState:UIControlStateNormal];
    [removebtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [removebtn addTarget:self action:@selector(removeCount) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:removebtn];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(150, 60, 140, 20)];
    [_slider setMaximumValue:300];
    [_slider setMinimumValue:0];
    [_slider setValue:_totalCount];
    [_slider addTarget:self action:@selector(sliderCount:) forControlEvents:UIControlEventValueChanged];
    [btnView addSubview:_slider];
    
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(btnView.frame.size.width-100, btnView.frame.size.height-30, 80, 20)];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:@"绘图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(drawChart) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:btn];
    
    
    
    
}

/**
 *  切换折线图和圆柱图
 *
 *  @param sender
 */
- (void)switchType:(id)sender
{
    UISwitch* swi = (UISwitch*)sender;
    if ([swi isOn]) {
        _chartType = @"bar";
    }else{
        _chartType = @"line";
    }
    [self drawChart];
}

/**
 *  使用滑动条来调整绘制点的数量
 *
 *  @param sender
 */
- (void)sliderCount:(id)sender
{
    UISlider* slider = (UISlider*)sender;
    _totalCount = slider.value;
    [_sliderLabel setText:[NSString stringWithFormat:@"点数量：%d",_totalCount] ];
    [self drawChart];
}

/**
 *  点击加号，添加单个点
 */
- (void)addCount{
    _totalCount++;
    [_sliderLabel setText:[NSString stringWithFormat:@"点数量：%d",_totalCount] ];
    [_slider setValue:_totalCount animated:YES];
    [self drawChart];
}

/**
 *  点击减号，移除单个点
 */
- (void)removeCount{
    if (_totalCount && _totalCount>0) {
        _totalCount--;
        [_sliderLabel setText:[NSString stringWithFormat:@"点数量：%d",_totalCount] ];
        [_slider setValue:_totalCount animated:YES];
        [self drawChart];
    }
}

/**
 *  图形绘制
 */
- (void)drawChart
{
    // 因为点的数量改变，需要重新绘制，所以移除之前的图形
    if (_chartView) {
        [_chartView removeFromSuperview];
        _chartView = nil;
    }
    
    if (_dic) {
        [_dic removeAllObjects];
        _dic = nil;
    }
    
    // 创建示例数据1，10的倍数递增
    _dic = [[NSMutableDictionary alloc] initWithCapacity:_totalCount];
    
    for (int i=1; i<=_totalCount; i++) {
        [_dic setObject:[NSString stringWithFormat:@"%d", i*10]  forKey:[NSString stringWithFormat:@"%d", i]];
    }
    _maxValue = 10*_totalCount;
    _minValue = 10;
    
    if (_dic1) {
        [_dic1 removeAllObjects];
        _dic1 = nil;
    }
    
    // 创建实例数据2，随机数
    _dic1 = [[NSMutableDictionary alloc] initWithCapacity:_totalCount];
    for (int i=1; i<=_totalCount; i++) {
        int y = (arc4random() % 10) + 20;
        [_dic1 setObject:[NSString stringWithFormat:@"%d", y*y]  forKey:[NSString stringWithFormat:@"%d", i]];
        
        if (y*y>_maxValue) {
            _maxValue = y*y;
        }
        if (y*y<_minValue) {
            _minValue = y*y;
        }
    }
    
    // 创建绘图组件
    _chartView = [[CYChartView alloc] initWithFrame:CGRectMake(30, 230, 250, 200)];
    _chartView.backgroundColor = [UIColor clearColor];
    _chartView.delegate = self; // 指定代理
    _chartView.chartType = _chartType; // 图形类型为折线or圆柱
    _chartView.needReferenceLine = NO; // 是否开启最大、最小值参考线
    
    [self.view addSubview:_chartView];
    
    [_chartView drawChartLayer]; // 开始绘制
}


#pragma CYChartViewDelegate

/**
 *  本实例有两组图形数据
 *
 *  @return 图形组数
 */
- (NSInteger)numberOfChartGroup{
    return 1; // 暂时只显示一组吧，另一组隐藏了
}

/**
 *  设置图形属性
 *
 *  @param chartView 绘图组件对象
 *  @param group     图形是第几组的索引
 *
 *  @return 图形属性对象
 */
- (CYGraphAttribute *)chartView:(CYChartView *)chartView graphAttributeForGroup:(NSInteger)group
{
    CYGraphAttribute* model = [[CYGraphAttribute alloc] init];
    model.maxValue = _maxValue; // 用于计算y轴最大值
    model.minValue = _minValue;
    model.pointsCount = _totalCount; // 用于计算x轴各点的间距
    
    if (group == 1) { // 设置第二组图形颜色为蓝色，第一组的group值为0，颜色默认为浅绿色
        model.graphColor = [UIColor colorWithRed:30.0/255.0f green:176.0/255.0f blue:255.0/255.0f alpha:1.0f];
    }
    return model;
}

/**
 *  设置在第几组图形中，第几个点的属性
 *
 *  @param chartView  组件对象
 *  @param pointIndex 点的位置索引
 *  @param chartGroup 图形组的索引
 *
 *  @return 点对象
 */
- (CYPoint*)chartView:(CYChartView *)chartView pointIndex:(NSInteger)pointIndex chartGroup:(NSInteger)chartGroup
{
    CYPoint* point = [[CYPoint alloc] initWithX:0 andY:0];
    
    // x/yvalue为真实值，会被用来转换计算坐标值；x/ylabeltext用于显示x/y轴和选中点后的提示层文字
    point.xValue = [NSString stringWithFormat:@"%d", pointIndex+1];
    if (chartGroup == 1) {
        point.yValue = [_dic objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
        point.xLabelText = [NSString stringWithFormat:@"%d", pointIndex+1];
        point.yLabelText = [_dic objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
        
        if (chartGroup==1) {
            point.xValue = [NSString stringWithFormat:@"%d", pointIndex+1+20];
            point.yValue = [_dic objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
            point.xLabelText = [NSString stringWithFormat:@"%d", pointIndex+1];
            point.yLabelText = [_dic objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
            
        }
    }else{
        
        point.yValue = [_dic1 objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
        point.xLabelText = [NSString stringWithFormat:@"%d", pointIndex+1];
        point.yLabelText = [_dic1 objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
        
        if (chartGroup==1) {
            point.xValue = [NSString stringWithFormat:@"%d", pointIndex+1+20];
            point.yValue = [_dic1 objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
            point.xLabelText = [NSString stringWithFormat:@"%d", pointIndex+1];
            point.yLabelText = [_dic1 objectForKey:[NSString stringWithFormat:@"%d", pointIndex+1]];
            
        }
    }
    
    return point;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
