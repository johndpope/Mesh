//
//  WSMButton.m
//  wrkstrm
//
//  Created by Cristian Monterroza on 9/14/13.
//  Copyright (c) 2013 Subprime Insight. All rights reserved.
//

#import "WSMButton.h"

@interface WSMButton ()

@end

@implementation WSMButton

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.currentIdentityTransform = CGAffineTransformIdentity;
//    [self createShadow];
}

- (void)createShadow {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 3;

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
	self.layer.masksToBounds = self.isEnabled ? NO : YES;
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowRadius = 2;
	self.layer.shadowPath = shadowPath.CGPath;

    UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset.width"
                                                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontal.minimumRelativeValue = @-3.5;
    horizontal.maximumRelativeValue = @3.5;

    UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"layer.shadowOffset.height"
                                                                                            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    vertical.minimumRelativeValue = @-2.5;
    vertical.maximumRelativeValue = @3.5;

    [self addMotionEffect:horizontal];
    [self addMotionEffect:vertical];
}

- (void)pulseView:(BOOL)pulse {
	[self pulseView:pulse withDelay:0.0f];
}

- (void)pulseView:(BOOL)pulse withDelay:(CGFloat)delay {
    if (pulse) {
        CGFloat scaleFactor = 0.9;
        [UIView animateWithDuration:2 delay:delay
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat |
         UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                         animations:^
         {
             self.transform = CGAffineTransformScale(self.currentIdentityTransform, scaleFactor, scaleFactor);
         } completion: nil];
    } else {
        [UIView animateWithDuration:2.0f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.transform = self.currentIdentityTransform;
        } completion: nil];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.layer.masksToBounds = !enabled;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.masksToBounds = selected;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.layer.masksToBounds = highlighted;
}

@end
