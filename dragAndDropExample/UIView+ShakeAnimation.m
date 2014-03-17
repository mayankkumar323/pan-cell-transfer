//
//  UIView+ShakeAnimation.m
//  dragAndDropExample
//
//  Created by Mayank Home on 3/16/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "UIView+ShakeAnimation.h"
static NSString *rotationAnimationKey = @"layerRotationAnimationKey";
static NSString *translationAnimationKey = @"layertranslationAnimationKey";

@implementation UIView (ShakeAnimation)

- (void) startShakeAnimation {
    [self addRotationAnimation];
    [self addTranslationAnimation];
}

- (void) stopShakeAnimation {
    [self.layer removeAnimationForKey:rotationAnimationKey];
    [self.layer removeAnimationForKey:translationAnimationKey];
}

- (void) addRotationAnimation {
    if ([self.layer animationForKey:rotationAnimationKey]) {
        return;
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.autoreverses = YES;
    rotationAnimation.duration = 1.f;

    rotationAnimation.fromValue = @(M_PI/100);
    rotationAnimation.toValue = @(-M_PI/100);
    
    [self.layer addAnimation:rotationAnimation forKey:rotationAnimationKey];
}

- (void) addTranslationAnimation {
    if ([self.layer animationForKey:translationAnimationKey]) {
        return;
    }
    CABasicAnimation *translationXAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    translationXAnimation.repeatCount = MAXFLOAT;
    translationXAnimation.duration = 2.f;
    translationXAnimation.autoreverses = YES;
    
    [translationXAnimation setFromValue:@(self.bounds.origin.x + 2.0)];
    [translationXAnimation setToValue:@(self.bounds.origin.x - 2.0)];
    
    [self.layer addAnimation:translationXAnimation forKey:translationAnimationKey];
}

@end
