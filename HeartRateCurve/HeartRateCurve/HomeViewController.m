//
//  HomeViewController.m
//  HeartRateCurve
//
//  Created by IOS－001 on 14-4-23.
//  Copyright (c) 2014年 N/A. All rights reserved.
//

#import "HomeViewController.h"
#import "HeartLive.h"

@interface HomeViewController ()

@property (nonatomic , strong) NSArray *dataSource;

@property (nonatomic , strong) HeartLive *refreshMoniterView;
@property (nonatomic , strong) HeartLive *translationMoniterView;

@end

@implementation HomeViewController

- (HeartLive *)refreshMoniterView
{
    if (!_refreshMoniterView) {
        CGFloat xOffset = 10;
        _refreshMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(xOffset, 20, CGRectGetWidth(self.view.frame) - 2 * xOffset, 200)];
        _refreshMoniterView.backgroundColor = [UIColor blackColor];
    }
    return _refreshMoniterView;
}

- (HeartLive *)translationMoniterView
{
    if (!_translationMoniterView) {
        CGFloat xOffset = 10;
        _translationMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(xOffset, CGRectGetMaxY(self.refreshMoniterView.frame) + 10, CGRectGetWidth(self.view.frame) - 2 * xOffset, 200)];
        _translationMoniterView.backgroundColor = [UIColor blackColor];
    }
    return _translationMoniterView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"心电图";
    
    [self.view addSubview:self.refreshMoniterView];
    [self.view addSubview:self.translationMoniterView];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    void (^createData)(void) = ^{
        NSString *tempString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableArray *tempData = [[tempString componentsSeparatedByString:@","] mutableCopy];
        [tempData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *tempDataa = @(-[obj integerValue] + 2048);
            [tempData replaceObjectAtIndex:idx withObject:tempDataa];
        }];
        self.dataSource = tempData;
        [self createWorkDataSourceWithTimeInterval:0.01];
    };
    createData();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 哟

- (void)createWorkDataSourceWithTimeInterval:(NSTimeInterval )timeInterval
{
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerRefresnFun) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerTranslationFun) userInfo:nil repeats:YES];
}

//刷新方式绘制
- (void)timerRefresnFun
{
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    
    [self.refreshMoniterView fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];
}

//平移方式绘制
- (void)timerTranslationFun
{
    [[PointContainer sharedContainer] addPointAsTranslationChangeform:[self bubbleTranslationPoint]];
    
    [self.translationMoniterView fireDrawingWithPoints:[[PointContainer sharedContainer] translationPointContainer] pointsCount:[[PointContainer sharedContainer] numberOfTranslationElements]];
    
    //    printf("当前元素个数:%2d->",[PointContainer sharedContainer].numberOfElements);
    //    for (int k = 0; k != [PointContainer sharedContainer].numberOfElements; ++k) {
    //        printf("(%4.0f,%4.0f)",[PointContainer sharedContainer].pointContainer[k].x,[PointContainer sharedContainer].pointContainer[k].y);
    //    }
    //    putchar('\n');
    
}

#pragma mark -
#pragma mark - DataSource

- (CGPoint)bubbleRefreshPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    dataSourceCounterIndex ++;
    dataSourceCounterIndex %= [self.dataSource count];
    
    
    NSInteger pixelPerPoint = 1;
    static NSInteger xCoordinateInMoniter = 0;
    
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,[self.dataSource[dataSourceCounterIndex] integerValue] * 0.5 + 120};
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(CGRectGetWidth(self.translationMoniterView.frame));
    
    //    NSLog(@"吐出来的点:%@",NSStringFromCGPoint(targetPointToAdd));
    return targetPointToAdd;
}

- (CGPoint)bubbleTranslationPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    dataSourceCounterIndex ++;
    dataSourceCounterIndex %= [self.dataSource count];
    
    
    NSInteger pixelPerPoint = 1;
    static NSInteger xCoordinateInMoniter = 0;
    
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,[self.dataSource[dataSourceCounterIndex] integerValue] * 0.5 + 120};
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(CGRectGetWidth(self.translationMoniterView.frame));
    
    //    NSLog(@"吐出来的点:%@",NSStringFromCGPoint(targetPointToAdd));
    return targetPointToAdd;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end