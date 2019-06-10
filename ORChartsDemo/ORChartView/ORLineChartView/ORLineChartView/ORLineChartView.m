//
//  ORLineChartView.m
//  ORChartView
//
//  Created by OrangesAL on 2019/5/1.
//  Copyright © 2019年 欧阳荣. All rights reserved.
//

#import "ORLineChartView.h"
#import "ORLineChartCell.h"
#import "ORLineChartConfig.h"
#import "ORChartUtilities.h"

@implementation NSObject (ORLineChartView)

- (NSInteger)numberOfVerticalLinesOfChartView:(ORLineChartView *)chartView {return 5;};

- (id)chartView:(ORLineChartView *)chartView titleForHorizontalAtIndex:(NSInteger)index {return nil;};

- (NSDictionary<NSAttributedStringKey,id> *)labelAttrbutesForHorizontalOfChartView:(ORLineChartView *)chartView {
    return @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
}
- (NSDictionary<NSAttributedStringKey,id> *)labelAttrbutesForVerticalOfChartView:(ORLineChartView *)chartView {
    return @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
}

- (NSAttributedString *)chartView:(ORLineChartView *)chartView attributedStringForIndicaterAtIndex:(NSInteger)index {return nil;}

@end

@interface _ORIndicatorView : UIView
@end

@implementation _ORIndicatorView {
    UILabel *_label;
    CAShapeLayer *_backLayer;
    CALayer *_shadowLayer;
}

#pragma mark - Initailize Methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _xw_initailizeUI];
    }
    return self;
}


- (void)_xw_initailizeUI{
    _label = ({
        UILabel *label = [UILabel new];
        label;
    });
    [self addSubview:_label];

    
    _backLayer = ({
        CAShapeLayer *layer = [CAShapeLayer new];
        layer.fillColor = [UIColor redColor].CGColor;
        layer;
    });
    
    [self.layer insertSublayer:_backLayer atIndex:0];
    
    _shadowLayer = ({
        CALayer *layer = [CALayer new];
        layer;
    });
    [self.layer insertSublayer:_shadowLayer atIndex:0];
}

- (void)or_setTitle:(NSAttributedString *)title {
    _label.attributedText = title;
    [_label sizeToFit];
    CGFloat width = _label.bounds.size.width + 10;
    CGFloat height = _label.bounds.size.height + 10;
    self.bounds = CGRectMake(0, 0, width, height);
    _label.center = CGPointMake(width / 2.0, (height - 3.78) / 2.0);
    
    _backLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, height - 3.78) cornerRadius:3];
        UIBezierPath *anglePath = [UIBezierPath bezierPath];
        [anglePath moveToPoint:CGPointMake(width / 2.0f, height)];
        [anglePath addLineToPoint:CGPointMake(width / 2.0 - 3.5, height - 3.78)];
        [anglePath addLineToPoint:CGPointMake(width / 2.0 + 3.5, height - 3.78)];
        [anglePath addLineToPoint:CGPointMake(width / 2.0f, height)];
        [path appendPath:anglePath];
        path.CGPath;
    });
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backLayer.fillColor = backgroundColor.CGColor;
}

@end

@interface ORLineChartView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSInteger _lastIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <UILabel *>*leftLabels;

@property (nonatomic, strong) NSMutableArray <ORLineChartHorizontal *>*horizontalDatas;

@property (nonatomic, strong) ORLineChartConfig *config;
@property (nonatomic, strong) ORLineChartValue *lineChartValue;
@property (nonatomic, strong) CAShapeLayer *bottomLineLayer;
@property (nonatomic, strong) CAShapeLayer *bgLineLayer;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *closeLayer;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLineLayer;

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic, strong) CALayer *animationLayer;
@property (nonatomic, strong) _ORIndicatorView *indicator;
@property (nonatomic, strong) CALayer *indicatorLineLayer;

@property (nonatomic, strong) CALayer *contenLayer;

@property (nonatomic, assign) CGFloat bottomTextHeight;


@end

@implementation ORLineChartView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _or_initData];
        [self _or_initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _or_initData];
        [self _or_initUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _or_layoutSubviews];
}

- (void)_or_initUI {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _collectionView = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.scrollsToTop = NO;
        [collectionView registerClass:[ORLineChartCell class] forCellWithReuseIdentifier:NSStringFromClass([ORLineChartCell class])];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView;
    });
    [self addSubview:_collectionView];
    
    _bgLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_bgLineLayer];
    
    _bottomLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_bottomLineLayer];
    
    
    
    _gradientLayer = ({
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.masksToBounds = YES;
        gradientLayer.locations = @[@(0.5f)];
        gradientLayer;
    });
//    [_collectionView.layer addSublayer:_gradientLayer];
    
    _closeLayer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
    _closeLayer.fillColor = [UIColor blueColor].CGColor;

//    _gradientLayer.mask = _closeLayer;
    
    CALayer *baseLayer = [CALayer layer];
    [baseLayer addSublayer:_gradientLayer];
    [baseLayer setMask:_closeLayer];
    _contenLayer = baseLayer;
    [_collectionView.layer addSublayer:baseLayer];

    
    
    _lineLayer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
    [_collectionView.layer addSublayer:_lineLayer];
    
    _shadowLineLayer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
    [_collectionView.layer addSublayer:_shadowLineLayer];
    
    _indicatorLineLayer = ({
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = [UIColor blackColor].CGColor;
        layer;
    });
    
    [_collectionView.layer addSublayer:_indicatorLineLayer];

    
    _circleLayer = ({
        CAShapeLayer *layer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
        layer.fillColor = self.backgroundColor.CGColor;
        layer.speed = 0.0f;
        layer;
    });
    [_collectionView.layer addSublayer:_circleLayer];
    
    
    _animationLayer = ({
        CALayer *layer = [CALayer new];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.speed = 0.0f;
        layer;
    });
    [_collectionView.layer addSublayer:_animationLayer];
    
    _indicator = [_ORIndicatorView new];;
    [_collectionView addSubview:_indicator];

}

- (void)_or_initData {
    
    _leftLabels = [NSMutableArray array];
    _horizontalDatas = [NSMutableArray array];
    _config = [ORLineChartConfig new];
}

- (void)_or_configChart {
    
    _lineLayer.strokeColor = _config.chartLineColor.CGColor;
    _shadowLineLayer.strokeColor = _config.shadowLineColor.CGColor;
    _lineLayer.lineWidth = _config.lineWidth;
    _shadowLineLayer.lineWidth = _config.lineWidth * 0.8;
    
    
    _circleLayer.frame = (CGRect){{0,0},{_config.circleWidth,_config.circleWidth}};
    _circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:_circleLayer.frame].CGPath;
    _circleLayer.lineWidth = _config.lineWidth;
    _circleLayer.strokeColor = _config.chartLineColor.CGColor;
    
    _gradientLayer.colors = _config.gradientColors;
    
    _bgLineLayer.strokeColor = _config.bgLineColor.CGColor;
    _bgLineLayer.lineDashPattern = @[@(1.5), @(_config.dottedBGLine ? 3 : 0)];
    _bgLineLayer.lineWidth = _config.bglineWidth;

    _bottomLineLayer.strokeColor = _config.bgLineColor.CGColor;
    _bottomLineLayer.lineWidth = _config.bglineWidth;
    
    if (self.horizontalDatas.count > 0) {
        _bottomTextHeight = [self.horizontalDatas.firstObject.title boundingRectWithSize:CGSizeMake(_config.bottomLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading context:nil].size.height + _config.bottomLabelInset;
    }
    
    _indicator.backgroundColor = _config.indicatorTintColor;
    
    [self.collectionView reloadData];
    [self setNeedsLayout];
}

- (void)_or_layoutSubviews {
        
//    self.collectionView.contentInset = UIEdgeInsetsMake(topHeight, 0, bottowHeight, 0);
    
    _circleLayer.fillColor = self.backgroundColor.CGColor;
    
    self.collectionView.frame = CGRectMake(_config.leftWidth,
                                           _config.topInset,
                                           self.bounds.size.width - _config.leftWidth,
                                           self.bounds.size.height - _config.topInset - _config.bottomInset);
    
    _gradientLayer.frame = CGRectMake(0, 0, 0, self.collectionView.bounds.size.height);
    
    CGFloat indecaterHeight = _indicator.bounds.size.height;

    
    CGFloat topHeight = indecaterHeight * 2;
    
    CGFloat height = self.collectionView.bounds.size.height;
    
    CGFloat labelHeight = (height - topHeight - _bottomTextHeight) / (self.leftLabels.count - 1);
    
    CGFloat labelInset = 0;
    
    
    if (self.leftLabels.count > 0) {
        
        [self.leftLabels.firstObject sizeToFit];
        labelInset = labelHeight - self.leftLabels.firstObject.bounds.size.height;
        labelHeight =  self.leftLabels.firstObject.bounds.size.height;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self.leftLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.frame = CGRectMake(0, self.bounds.size.height - self.bottomTextHeight - self.config.bottomInset - labelHeight * 0.5   - (labelHeight + labelInset) * idx, self.config.leftWidth, labelHeight);
        
        if (idx > 0) {
            [path moveToPoint:CGPointMake(self.config.leftWidth, obj.center.y)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, obj.center.y)];
        }else {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(self.config.leftWidth, obj.center.y)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, obj.center.y)];
            self.bottomLineLayer.path = path.CGPath;
        }
    }];
    
    _bgLineLayer.path = path.CGPath;
    
    CGFloat ratio = (self.lineChartValue.max == self.lineChartValue.min) ? (float)1 :(CGFloat)(self.lineChartValue.min - self.lineChartValue.max);

    NSMutableArray *points = [NSMutableArray array];
    
    [self.horizontalDatas enumerateObjectsUsingBlock:^(ORLineChartHorizontal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        

        CGFloat y = ORInterpolation(topHeight, height - self.bottomTextHeight, (obj.value - self.lineChartValue.max) / ratio);
        
        if (idx == 0) {
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, y)]];
        }
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(self.config.bottomLabelWidth * 0.5 + idx * self.config.bottomLabelWidth, y)]];
        
        if (idx == self.horizontalDatas.count - 1) {
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(self.config.bottomLabelWidth * self.horizontalDatas.count , y)]];
        }
    }];
    
    BOOL isCurve = !self.config.isBreakLine;
    
    UIBezierPath *linePath = [ORChartUtilities or_pathWithPoints:points isCurve:isCurve];
    _lineLayer.path = [linePath.copy CGPath];
    
    [linePath applyTransform:CGAffineTransformMakeTranslation(0, 8)];
    _shadowLineLayer.path = [linePath.copy CGPath];
    
    _closeLayer.path = [ORChartUtilities or_closePathWithPoints:points isCurve:isCurve maxY: height - self.bottomTextHeight].CGPath;
    
    
    [points removeLastObject];
    [points removeObjectAtIndex:0];
    UIBezierPath *ainmationPath = [ORChartUtilities or_pathWithPoints:points isCurve:isCurve];
    
    [_circleLayer removeAnimationForKey:@"or_circleMove"];
    [_circleLayer addAnimation:[self _or_positionAnimationWithPath:[ainmationPath.copy CGPath]] forKey:@"or_circleMove"];
    
//    CGFloat indecaterHeight = _indicator.bounds.size.height;
    
    [ainmationPath applyTransform:CGAffineTransformMakeTranslation(0, - indecaterHeight)];
    [_animationLayer removeAnimationForKey:@"or_circleMove"];
    [_animationLayer addAnimation:[self _or_positionAnimationWithPath:ainmationPath.CGPath] forKey:@"or_circleMove"];

    CGPoint fistValue = [points.firstObject CGPointValue];
    _indicator.center = CGPointMake(fistValue.x, fistValue.y - indecaterHeight);
    [self _or_updateIndcaterLineFrame];

    [_lineLayer addAnimation:[ORChartUtilities or_strokeAnimationWithDurantion:2] forKey:nil];
    [_shadowLineLayer addAnimation:[ORChartUtilities or_strokeAnimationWithDurantion:2] forKey:nil];

//    _gradientLayer.anchorPoint = CGPointMake(0, 0.5);
    CABasicAnimation *anmi1 = [CABasicAnimation animation];
    anmi1.keyPath = @"bounds.size.width";
    anmi1.duration = 2.0f;
    anmi1.toValue = @( _config.bottomLabelWidth * _horizontalDatas.count * 2);

    anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anmi1.fillMode = kCAFillModeForwards;
    anmi1.autoreverses = NO;
    anmi1.removedOnCompletion = NO;
    [_gradientLayer addAnimation:anmi1 forKey:nil];

}

- (CAAnimation *)_or_positionAnimationWithPath:(CGPathRef)path {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 1.0f;
    animation.path = path;
    return animation;
}

- (void)_or_updateIndcaterLineFrame {
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGFloat midY = CGRectGetMidY(self.leftLabels.firstObject.frame);
    _indicatorLineLayer.frame = CGRectMake(_indicator.center.x - _config.indicatorLineWidth / 2.0, CGRectGetMaxY(_indicator.frame), _config.indicatorLineWidth, midY - CGRectGetMaxY(_indicator.frame));
    [CATransaction commit];
}

- (void)reloadData {
    
    if (!_dataSource || [_dataSource numberOfHorizontalDataOfChartView:self] == 0) {
        return;
    }
    
    NSInteger items = [_dataSource numberOfHorizontalDataOfChartView:self];
    
    for (int i = 0; i < items; i ++) {
        
        ORLineChartHorizontal *horizontal = [ORLineChartHorizontal new];
        horizontal.value = [_dataSource chartView:self valueForHorizontalAtIndex:i];
        
        horizontal.title = [[NSAttributedString alloc] initWithString:[_dataSource chartView:self titleForHorizontalAtIndex:i] attributes:[_dataSource labelAttrbutesForHorizontalOfChartView:self]];
        
        [self.horizontalDatas addObject:horizontal];
    }
    
    NSInteger vertical = [_dataSource numberOfVerticalLinesOfChartView:self];
    
    _lineChartValue = [[ORLineChartValue alloc] initWithHorizontalData:self.horizontalDatas numberWithSeparate:vertical];
    
    if (self.leftLabels.count > vertical) {
        for (NSInteger i = vertical; i < _leftLabels.count; i ++) {
            UILabel *label = _leftLabels[i];
            [label removeFromSuperview];
            [_leftLabels removeObject:label];
        }
    }else if (self.leftLabels.count < vertical) {
        for (NSInteger i = self.leftLabels.count; i < vertical; i ++) {
            UILabel *label = [UILabel new];
            label.textAlignment = NSTextAlignmentCenter;
            [_leftLabels addObject:label];
            [self addSubview:label];
        }
    }
    
    [self.leftLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.lineChartValue.separatedValues[idx]] attributes:[self.dataSource labelAttrbutesForVerticalOfChartView:self]];
    }];
    
    NSAttributedString *title = [_dataSource chartView:self attributedStringForIndicaterAtIndex:0];
    if (!title) {
        title = self.leftLabels.firstObject.attributedText;
    }
    [_indicator or_setTitle:title];
    
    [self _or_configChart];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.horizontalDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ORLineChartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ORLineChartCell class]) forIndexPath:indexPath];
    cell.horizontal = self.horizontalDatas[indexPath.row];
    cell.config = self.config;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_config.bottomLabelWidth, collectionView.bounds.size.height);//collectionView.bounds.size.height
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat ratio = (scrollView.contentOffset.x + scrollView.contentInset.left) / (scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right - scrollView.bounds.size.width);
    ratio = fmin(fmax(0.0, ratio), 1.0);

    _circleLayer.timeOffset = ratio;
    _animationLayer.timeOffset = ratio;
    _indicator.center = _animationLayer.presentationLayer.position;
    [self _or_updateIndcaterLineFrame];
    
    NSInteger index = floor(_indicator.center.x / _config.bottomLabelWidth);
    
    if (index == _lastIndex) {
        return;
    }
    NSAttributedString *title = [_dataSource chartView:self attributedStringForIndicaterAtIndex:index];
    if (!title) {
        title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%g", self.horizontalDatas[index].value]];
    }
    _lastIndex = index;
    [_indicator or_setTitle:title];
    
}

#pragma mark -- setter
- (void)setDataSource:(id<ORLineChartViewDataSource>)dataSource {
    
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        if (_dataSource) {
            [self reloadData];
        }
    }
}

- (void)setDelegate:(id<ORLineChartViewDelegate>)delegate {
    
    if (_delegate != delegate) {
        _delegate = delegate;
        if (_dataSource) {
//            [self _or_setDelegateData];
            [self setNeedsLayout];
        }
    }
}

- (void)setConfig:(ORLineChartConfig *)config {
    if (_config != config) {
        _config = config;
        if (_dataSource) {
            [self _or_configChart];
        }
    }
}

@end
