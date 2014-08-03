//
//  WSMMeshLogoButton.m
//  Mesh
//
//  Created by Cristian Monterroza on 7/31/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import "WSMMeshLogoButton.h"

@implementation WSMMeshLogoButton

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    [self createShadowEffect];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    [self createShadowEffect];
    return self;
}

- (void)createShadowEffect {
	self.layer.masksToBounds = self.isEnabled ? NO : YES;
	self.layer.shadowColor = [UIColor purpleColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowRadius = 1.0f;
    
	self.layer.shadowPath = self.textPath.CGPath;
    
    UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset.width"
                                                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontal.minimumRelativeValue = @-15;
    horizontal.maximumRelativeValue = @20;
    
    UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset.height"
                                                                                            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    vertical.minimumRelativeValue = @-15;
    vertical.maximumRelativeValue = @20;
    
    [self addMotionEffect:horizontal];
    [self addMotionEffect:vertical];
}

- (UIBezierPath *)textPath {
    return WSM_LAZY(_textPath, ({
        
        //// Text Drawing
        UIBezierPath *textPath = UIBezierPath.bezierPath;
        [textPath moveToPoint: CGPointMake(5.83, 84.64)];
        [textPath addLineToPoint: CGPointMake(16.64, 8.53)];
        [textPath addLineToPoint: CGPointMake(17.81, 8.53)];
        [textPath addLineToPoint: CGPointMake(48.76, 70.97)];
        [textPath addLineToPoint: CGPointMake(79.5, 8.53)];
        [textPath addLineToPoint: CGPointMake(80.67, 8.53)];
        [textPath addLineToPoint: CGPointMake(91.58, 84.64)];
        [textPath addLineToPoint: CGPointMake(84.06, 84.64)];
        [textPath addLineToPoint: CGPointMake(76.64, 30.16)];
        [textPath addLineToPoint: CGPointMake(49.71, 84.64)];
        [textPath addLineToPoint: CGPointMake(47.81, 84.64)];
        [textPath addLineToPoint: CGPointMake(20.56, 29.73)];
        [textPath addLineToPoint: CGPointMake(13.14, 84.64)];
        [textPath addLineToPoint: CGPointMake(5.83, 84.64)];
        [textPath closePath];
        [textPath moveToPoint: CGPointMake(106.74, 8.53)];
        [textPath addLineToPoint: CGPointMake(150.41, 8.53)];
        [textPath addLineToPoint: CGPointMake(150.41, 16.06)];
        [textPath addLineToPoint: CGPointMake(114.37, 16.06)];
        [textPath addLineToPoint: CGPointMake(114.37, 39.8)];
        [textPath addLineToPoint: CGPointMake(150.1, 39.8)];
        [textPath addLineToPoint: CGPointMake(150.1, 47.22)];
        [textPath addLineToPoint: CGPointMake(114.37, 47.22)];
        [textPath addLineToPoint: CGPointMake(114.37, 77.11)];
        [textPath addLineToPoint: CGPointMake(150.1, 77.11)];
        [textPath addLineToPoint: CGPointMake(150.1, 84.64)];
        [textPath addLineToPoint: CGPointMake(106.74, 84.64)];
        [textPath addLineToPoint: CGPointMake(106.74, 8.53)];
        [textPath closePath];
        [textPath moveToPoint: CGPointMake(155.61, 70.44)];
        [textPath addLineToPoint: CGPointMake(162.07, 66.62)];
        [textPath addCurveToPoint: CGPointMake(177.87, 79.13) controlPoint1: CGPointMake(166.6, 74.96) controlPoint2: CGPointMake(171.86, 79.13)];
        [textPath addCurveToPoint: CGPointMake(187.83, 75.42) controlPoint1: CGPointMake(181.75, 79.13) controlPoint2: CGPointMake(185.08, 77.89)];
        [textPath addCurveToPoint: CGPointMake(191.97, 66.2) controlPoint1: CGPointMake(190.59, 72.94) controlPoint2: CGPointMake(191.97, 69.87)];
        [textPath addCurveToPoint: CGPointMake(188.47, 57.4) controlPoint1: CGPointMake(191.97, 63.3) controlPoint2: CGPointMake(190.8, 60.37)];
        [textPath addCurveToPoint: CGPointMake(176.86, 46.85) controlPoint1: CGPointMake(186.14, 54.43) controlPoint2: CGPointMake(182.27, 50.91)];
        [textPath addCurveToPoint: CGPointMake(165.94, 37.74) controlPoint1: CGPointMake(171.45, 42.79) controlPoint2: CGPointMake(167.82, 39.75)];
        [textPath addCurveToPoint: CGPointMake(161.81, 31.27) controlPoint1: CGPointMake(164.07, 35.72) controlPoint2: CGPointMake(162.69, 33.57)];
        [textPath addCurveToPoint: CGPointMake(160.48, 24.33) controlPoint1: CGPointMake(160.93, 28.97) controlPoint2: CGPointMake(160.48, 26.66)];
        [textPath addCurveToPoint: CGPointMake(165.73, 11.77) controlPoint1: CGPointMake(160.48, 19.38) controlPoint2: CGPointMake(162.23, 15.19)];
        [textPath addCurveToPoint: CGPointMake(178.93, 6.62) controlPoint1: CGPointMake(169.23, 8.34) controlPoint2: CGPointMake(173.63, 6.62)];
        [textPath addCurveToPoint: CGPointMake(189.85, 9.75) controlPoint1: CGPointMake(183.1, 6.62) controlPoint2: CGPointMake(186.74, 7.67)];
        [textPath addCurveToPoint: CGPointMake(198.86, 19.03) controlPoint1: CGPointMake(192.96, 11.84) controlPoint2: CGPointMake(195.96, 14.93)];
        [textPath addLineToPoint: CGPointMake(192.71, 23.8)];
        [textPath addCurveToPoint: CGPointMake(186.56, 17.12) controlPoint1: CGPointMake(190.73, 21.11) controlPoint2: CGPointMake(188.68, 18.88)];
        [textPath addCurveToPoint: CGPointMake(178.77, 14.47) controlPoint1: CGPointMake(184.44, 15.35) controlPoint2: CGPointMake(181.84, 14.47)];
        [textPath addCurveToPoint: CGPointMake(171.24, 17.22) controlPoint1: CGPointMake(175.69, 14.47) controlPoint2: CGPointMake(173.19, 15.39)];
        [textPath addCurveToPoint: CGPointMake(168.33, 24.22) controlPoint1: CGPointMake(169.3, 19.06) controlPoint2: CGPointMake(168.33, 21.39)];
        [textPath addCurveToPoint: CGPointMake(170.93, 31.59) controlPoint1: CGPointMake(168.33, 27.05) controlPoint2: CGPointMake(169.19, 29.5)];
        [textPath addCurveToPoint: CGPointMake(182.69, 41.5) controlPoint1: CGPointMake(172.66, 33.67) controlPoint2: CGPointMake(176.58, 36.98)];
        [textPath addCurveToPoint: CGPointMake(196.05, 54.01) controlPoint1: CGPointMake(188.8, 46.02) controlPoint2: CGPointMake(193.26, 50.19)];
        [textPath addCurveToPoint: CGPointMake(200.23, 66.09) controlPoint1: CGPointMake(198.84, 57.82) controlPoint2: CGPointMake(200.23, 61.85)];
        [textPath addCurveToPoint: CGPointMake(193.82, 80.45) controlPoint1: CGPointMake(200.23, 71.6) controlPoint2: CGPointMake(198.1, 76.39)];
        [textPath addCurveToPoint: CGPointMake(178.93, 86.55) controlPoint1: CGPointMake(189.55, 84.52) controlPoint2: CGPointMake(184.58, 86.55)];
        [textPath addCurveToPoint: CGPointMake(155.61, 70.44) controlPoint1: CGPointMake(168.96, 86.55) controlPoint2: CGPointMake(161.19, 81.18)];
        [textPath closePath];
        [textPath moveToPoint: CGPointMake(216.13, 8.53)];
        [textPath addLineToPoint: CGPointMake(223.87, 8.53)];
        [textPath addLineToPoint: CGPointMake(223.87, 40.44)];
        [textPath addLineToPoint: CGPointMake(262.56, 40.44)];
        [textPath addLineToPoint: CGPointMake(262.56, 8.53)];
        [textPath addLineToPoint: CGPointMake(270.19, 8.53)];
        [textPath addLineToPoint: CGPointMake(270.19, 84.64)];
        [textPath addLineToPoint: CGPointMake(262.56, 84.64)];
        [textPath addLineToPoint: CGPointMake(262.56, 47.86)];
        [textPath addLineToPoint: CGPointMake(223.87, 47.86)];
        [textPath addLineToPoint: CGPointMake(223.87, 84.64)];
        [textPath addLineToPoint: CGPointMake(216.13, 84.64)];
        [textPath addLineToPoint: CGPointMake(216.13, 8.53)];
        [textPath closePath];
        textPath;
    }));
}

// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [UIColor.blackColor setFill];
    [self.textPath fill];
    // Drawing code
}

@end
