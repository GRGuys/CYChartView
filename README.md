# CYChartView
CYChartView是一个简单的趋势图绘制组件。
>-它能够自定义图形组数、颜色、文字描述等属性，方便定制；<br/>
>-图形会根据点的数值自动计算Y轴刻度，并保持图形居中显示；<br/>
>-同时在X轴也会根据点的数量来计算排列间隔，以及该点在X轴刻度的显示与否；<br/>
>-在实现代理方法后，只需指定每一个点的属性即可，不需要使用数组或字典单独保存各点的坐标和显示值。<br/>
<br/>

#使用步骤：
>-首先自然是引入CYChartView并实现代理CYChartViewDelegate，其次是创建该图标视图
```c
    _chartView = [[CYChartView alloc] initWithFrame:CGRectMake(30, 230, 250, 200)];
    _chartView.backgroundColor = [UIColor clearColor];
    _chartView.delegate = self;
    [self.view addSubview:_chartView];
```
>-然后实现代理方法，设置图形组数、图表属性及各点的数据显示
```c
    - (NSInteger)numberOfChartGroup{
      return 1; 
    }
    
    - (CYGraphAttribute *)chartView:(CYChartView *)chartView graphAttributeForGroup:(NSInteger)group
    {
      CYGraphAttribute* model = [[CYGraphAttribute alloc] init];
      model.maxValue = 10;
      model.minValue = 0;
      model.pointsCount = 10;
      return model;
    }
    
    - (CYPoint*)chartView:(CYChartView *)chartView pointIndex:(NSInteger)pointIndex chartGroup:(NSInteger)chartGroup
    {
      CYPoint* point = [[CYPoint alloc] initWithX:0 andY:0];
      point.xValue = point.yValue = point.xLabelText = point.yLabelText = pointIndex;
      return point;
    }
    
```
>-最后执行[_chartView drawChartLayer]; 方法绘制即可。
