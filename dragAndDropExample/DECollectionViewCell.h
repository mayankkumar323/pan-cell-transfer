//
//  DECollectionViewCell.h
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DECollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic) BOOL isPlaceHolder;
@end
