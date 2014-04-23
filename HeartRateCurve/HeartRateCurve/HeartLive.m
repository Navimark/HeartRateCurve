//
//  HeartLive.m
//  HeartRateCurve
//
//  Created by IOS－001 on 14-4-23.
//  Copyright (c) 2014年 N/A. All rights reserved.
//

#import "HeartLive.h"

static const NSInteger kMaxContainerCapacity = 300;

@interface PointContainer ()
@property (nonatomic , assign) NSInteger numberOfRefreshElements;
@property (nonatomic , assign) NSInteger numberOfTranslationElements;

@property (nonatomic , assign) CGPoint *refreshPointContainer;
@property (nonatomic , assign) CGPoint *translationPointContainer;

@end

@implementation PointContainer

- (void)dealloc
{
    free(self.refreshPointContainer);
    free(self.translationPointContainer);
    self.refreshPointContainer = self.translationPointContainer = NULL;
}

+ (PointContainer *)sharedContainer
{
    static PointContainer *container_ptr = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        container_ptr = [[self alloc] init];
        container_ptr.refreshPointContainer = malloc(sizeof(CGPoint) * kMaxContainerCapacity);
        memset(container_ptr.refreshPointContainer, 0, sizeof(CGPoint) * kMaxContainerCapacity);
        
        container_ptr.translationPointContainer = malloc(sizeof(CGPoint) * kMaxContainerCapacity);
        memset(container_ptr.translationPointContainer, 0, sizeof(CGPoint) * kMaxContainerCapacity);
    });
    return container_ptr;
}

- (void)addPointAsRefreshChangeform:(CGPoint)point
{
    static NSInteger currentPointsCount = 0;
    if (currentPointsCount < kMaxContainerCapacity) {
        self.numberOfRefreshElements = currentPointsCount + 1;
        self.refreshPointContainer[currentPointsCount] = point;
        currentPointsCount ++;
    } else {
        NSInteger workIndex = 0;
        while (workIndex != kMaxContainerCapacity - 1) {
            self.refreshPointContainer[workIndex] = self.refreshPointContainer[workIndex + 1];
            workIndex ++;
        }
        self.refreshPointContainer[kMaxContainerCapacity - 1] = point;
        self.numberOfRefreshElements = kMaxContainerCapacity;
    }
    
    //    printf("当前元素个数:%2d->",self.numberOfRefreshElements);
    //    for (int k = 0; k != kMaxContainerCapacity; ++k) {
    //        printf("(%4.0f,%4.0f)",self.refreshPointContainer[k].x,self.refreshPointContainer[k].y);
    //    }
    //    putchar('\n');
}

- (void)addPointAsTranslationChangeform:(CGPoint)point
{
    static NSInteger currentPointsCount = 0;
    if (currentPointsCount < kMaxContainerCapacity) {
        self.numberOfTranslationElements = currentPointsCount + 1;
        self.translationPointContainer[currentPointsCount] = point;
        currentPointsCount ++;
    } else {
        NSInteger workIndex = kMaxContainerCapacity - 1;
        while (workIndex != 0) {
            self.translationPointContainer[workIndex].y = self.translationPointContainer[workIndex - 1].y;
            workIndex --;
        }
        self.translationPointContainer[0].x = 0;
        self.translationPointContainer[0].y = point.y;
        self.numberOfTranslationElements = kMaxContainerCapacity;
    }
    
    //    printf("当前元素个数:%2d->",self.numberOfTranslationElements);
    //    for (int k = 0; k != self.numberOfTranslationElements; ++k) {
    //        printf("(%.0f,%.0f)",self.translationPointContainer[k].x,self.translationPointContainer[k].y);
    //    }
    //    putchar('\n');
}

@end

@interface HeartLive ()

@property (nonatomic , assign) CGPoint *points;
@property (nonatomic , assign) NSInteger currentPointsCount;

@end

@implementation HeartLive

- (void)setPoints:(CGPoint *)points
{
    _points = points;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (void)drawGrid
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat full_height = self.frame.size.height;
	CGFloat full_width = self.frame.size.width;
	CGFloat cell_square_width = 30;
	
	CGContextSetLineWidth(context, 0.2);
	CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
	
	int pos_x = 1;
	while (pos_x < full_width) {
		CGContextMoveToPoint(context, pos_x, 1);
		CGContextAddLineToPoint(context, pos_x, full_height);
		pos_x += cell_square_width;
		
		CGContextStrokePath(context);
	}
    
	CGFloat pos_y = 1;
	while (pos_y <= full_height) {
		
		CGContextSetLineWidth(context, 0.2);
        
		CGContextMoveToPoint(context, 1, pos_y);
		CGContextAddLineToPoint(context, full_width, pos_y);
		pos_y += cell_square_width;
		
		CGContextStrokePath(context);
	}
	
    
	CGContextSetLineWidth(context, 0.1);
    
	cell_square_width = cell_square_width / 5;
	pos_x = 1 + cell_square_width;
	while (pos_x < full_width) {
		CGContextMoveToPoint(context, pos_x, 1);
		CGContextAddLineToPoint(context, pos_x, full_height);
		pos_x += cell_square_width;
		
		CGContextStrokePath(context);
	}
	
	pos_y = 1 + cell_square_width;
	while (pos_y <= full_height) {
		CGContextMoveToPoint(context, 1, pos_y);
		CGContextAddLineToPoint(context, full_width, pos_y);
		pos_y += cell_square_width;
		
		CGContextStrokePath(context);
	}
    
}

- (void)fireDrawingWithPoints:(CGPoint *)points pointsCount:(NSInteger)count
{
    self.currentPointsCount = count;
    self.points = points;
}

- (void)drawCurve
{
    if (self.currentPointsCount == 0) {
        return;
    }
    CGFloat curveLineWidth = 0.8;
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext, curveLineWidth);
	CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor greenColor].CGColor);
    
    CGContextMoveToPoint(currentContext, self.points[0].x, self.points[0].y);
    for (int i = 1; i != self.currentPointsCount; ++ i) {
        if (self.points[i - 1].x < self.points[i].x) {
            CGContextAddLineToPoint(currentContext, self.points[i].x, self.points[i].y);
        } else {
            CGContextMoveToPoint(currentContext, self.points[i].x, self.points[i].y);
        }
    }
	CGContextStrokePath(UIGraphicsGetCurrentContext());
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawGrid];
    [self drawCurve];
}

@end