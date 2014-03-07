//
//  DECollectionViewCell.m
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "DECollectionViewCell.h"

@interface DECollectionViewCell ()
@property (nonatomic) UIView* placeHolderView;
@end

@implementation DECollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.placeHolderView = [[UIView alloc] initWithFrame:frame];
        self.placeHolderView.backgroundColor = [UIColor grayColor];
    }
    return self;
}

-(void)setImageView:(UIImageView *)imageView {
    if (_imageView == imageView) {
        return;
    }
    _imageView = imageView;
    _imageView.frame = self.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _imageView.layer.cornerRadius = 10.f;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    if (self.isPlaceHolder) {
        [self bringSubviewToFront:self.placeHolderView];
    }
}

- (void) setIsPlaceHolder:(BOOL)isPlaceHolder {
    if (_isPlaceHolder == isPlaceHolder) {
        return;
    }
    _isPlaceHolder = isPlaceHolder;
    if (isPlaceHolder) {
        self.placeHolderView.frame = self.bounds;
        [self addSubview:self.placeHolderView];
    } else {
        [self.placeHolderView removeFromSuperview];
    }
}

- (void)setGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (_gestureRecognizer==gestureRecognizer) {
        return;
    }
    _gestureRecognizer = gestureRecognizer;
    [self addGestureRecognizer:gestureRecognizer];
}

@end