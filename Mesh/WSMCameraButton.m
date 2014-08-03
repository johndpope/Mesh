//
//  WSMCameraButton.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/31/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMCameraButton.h"

@implementation WSMCameraButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.transform = CGAffineTransformScale(self.currentIdentityTransform, 2.0, 2.0);
//        self.currentIdentityTransform = self.transform;
    }
    return self;
}

- (UIBezierPath *)path {
    return WSM_LAZY(_path, ({
        //// Bezier Drawing
        UIBezierPath *bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(50, 30)];
        [bezierPath addCurveToPoint: CGPointMake(35, 45) controlPoint1: CGPointMake(41.72, 30) controlPoint2: CGPointMake(35, 36.72)];
        [bezierPath addCurveToPoint: CGPointMake(50, 60) controlPoint1: CGPointMake(35, 53.28) controlPoint2: CGPointMake(41.72, 60)];
        [bezierPath addCurveToPoint: CGPointMake(65, 45) controlPoint1: CGPointMake(58.28, 60) controlPoint2: CGPointMake(65, 53.28)];
        [bezierPath addCurveToPoint: CGPointMake(50, 30) controlPoint1: CGPointMake(65, 36.72) controlPoint2: CGPointMake(58.28, 30)];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(90, 15)];
        [bezierPath addLineToPoint: CGPointMake(78, 15)];
        [bezierPath addCurveToPoint: CGPointMake(74.05, 12.15) controlPoint1: CGPointMake(76.35, 15) controlPoint2: CGPointMake(74.57, 13.72)];
        [bezierPath addLineToPoint: CGPointMake(70.95, 2.84)];
        [bezierPath addCurveToPoint: CGPointMake(67, 0) controlPoint1: CGPointMake(70.43, 1.28) controlPoint2: CGPointMake(68.65, 0)];
        [bezierPath addLineToPoint: CGPointMake(33, 0)];
        [bezierPath addCurveToPoint: CGPointMake(29.05, 2.85) controlPoint1: CGPointMake(31.35, 0) controlPoint2: CGPointMake(29.57, 1.28)];
        [bezierPath addLineToPoint: CGPointMake(25.95, 12.16)];
        [bezierPath addCurveToPoint: CGPointMake(22, 15) controlPoint1: CGPointMake(25.43, 13.72) controlPoint2: CGPointMake(23.65, 15)];
        [bezierPath addLineToPoint: CGPointMake(10, 15)];
        [bezierPath addCurveToPoint: CGPointMake(0, 25) controlPoint1: CGPointMake(4.5, 15) controlPoint2: CGPointMake(0, 19.5)];
        [bezierPath addLineToPoint: CGPointMake(0, 70)];
        [bezierPath addCurveToPoint: CGPointMake(10, 80) controlPoint1: CGPointMake(0, 75.5) controlPoint2: CGPointMake(4.5, 80)];
        [bezierPath addLineToPoint: CGPointMake(90, 80)];
        [bezierPath addCurveToPoint: CGPointMake(100, 70) controlPoint1: CGPointMake(95.5, 80) controlPoint2: CGPointMake(100, 75.5)];
        [bezierPath addLineToPoint: CGPointMake(100, 25)];
        [bezierPath addCurveToPoint: CGPointMake(90, 15) controlPoint1: CGPointMake(100, 19.5) controlPoint2: CGPointMake(95.5, 15)];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(50, 70)];
        [bezierPath addCurveToPoint: CGPointMake(25, 45) controlPoint1: CGPointMake(36.19, 70) controlPoint2: CGPointMake(25, 58.81)];
        [bezierPath addCurveToPoint: CGPointMake(50, 20) controlPoint1: CGPointMake(25, 31.19) controlPoint2: CGPointMake(36.19, 20)];
        [bezierPath addCurveToPoint: CGPointMake(75, 45) controlPoint1: CGPointMake(63.8, 20) controlPoint2: CGPointMake(75, 31.19)];
        [bezierPath addCurveToPoint: CGPointMake(50, 70) controlPoint1: CGPointMake(75, 58.81) controlPoint2: CGPointMake(63.8, 70)];
        [bezierPath closePath];
        [bezierPath moveToPoint: CGPointMake(86.5, 31.99)];
        [bezierPath addCurveToPoint: CGPointMake(83, 28.49) controlPoint1: CGPointMake(84.57, 31.99) controlPoint2: CGPointMake(83, 30.43)];
        [bezierPath addCurveToPoint: CGPointMake(86.5, 24.99) controlPoint1: CGPointMake(83, 26.56) controlPoint2: CGPointMake(84.57, 24.99)];
        [bezierPath addCurveToPoint: CGPointMake(90, 28.49) controlPoint1: CGPointMake(88.43, 24.99) controlPoint2: CGPointMake(90, 26.56)];
        [bezierPath addCurveToPoint: CGPointMake(86.5, 31.99) controlPoint1: CGPointMake(90, 30.43) controlPoint2: CGPointMake(88.43, 31.99)];
        [bezierPath closePath];
        bezierPath;
    }));
}

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Group
    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, 5, 10);
    CGContextScaleCTM(context, 2, 2);
    
    
    [UIColor.blackColor setFill];
    [self.path fill];
}

@end
