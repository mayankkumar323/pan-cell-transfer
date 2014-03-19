//
//  DECollectionViewRotatingFlowLayout.m
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "DECollectionViewRotatingFlowLayout.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define ITEM_WIDTH 140  
#define ITEM_HEIGHT 160
#define LEFT_INSET ITEM_WIDTH/8
#define ROTATION_CENTER_VERTICAL_OFFSET 300
#define ROTATION_ANGLE_DIVIDER 4
#define SPACING_BETWEEN_CELLS -10

@implementation DECollectionViewRotatingFlowLayout

- (void)prepareLayout {
    CGFloat collectionViewHeight = self.collectionView.bounds.size.height;
    self.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    //the item height must be less that the height of the UICollectionView minus the section insets top and bottom values.
    self.sectionInset = UIEdgeInsetsMake(collectionViewHeight-ITEM_HEIGHT-1, LEFT_INSET, 0, ITEM_WIDTH/2);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = SPACING_BETWEEN_CELLS;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * array = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray * modifiedLayoutAttributesArray = [NSMutableArray array];
    
    CGFloat horizontalCenter = (CGRectGetWidth(self.collectionView.bounds) / 2.0f);
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * layoutAttributes, NSUInteger idx, BOOL *stop) {
        
        CGPoint pointInCollectionView = layoutAttributes.frame.origin;
        CGPoint pointInMainView = [self.collectionView.superview convertPoint:pointInCollectionView fromView:self.collectionView];
        
        CGPoint centerInCollectionView = layoutAttributes.center;
        CGPoint centerInMainView = [self.collectionView.superview convertPoint:centerInCollectionView fromView:self.collectionView];
        
        float rotateBy = 0.0f;
        CGPoint translateBy = CGPointZero;
        
        // we find out where this cell is relative to the center of the viewport, and invoke private methods to deduce the
        // amount of rotation to apply
        if (pointInMainView.x < self.collectionView.frame.size.width+80.0f){
            translateBy = [self calculateTranslateBy:horizontalCenter attribs:layoutAttributes];
            rotateBy = [self calculateRotationFromViewPortDistance:pointInMainView.x center:horizontalCenter]/ROTATION_ANGLE_DIVIDER;
            
            CGPoint rotationPoint = CGPointMake(self.collectionView.frame.size.width/2, self.collectionView.frame.size.height+ROTATION_CENTER_VERTICAL_OFFSET);
            
            // there are two transforms and one rotation. this is needed to make the view appear to have rotated around
            // a certain point.
            
            CATransform3D transform = CATransform3DIdentity;
            transform = CATransform3DTranslate(transform, rotationPoint.x - centerInMainView.x, rotationPoint.y - centerInMainView.y, 0.0);
            transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(-rotateBy), 0.0, 0.0, -1.0);
            transform = CATransform3DTranslate(transform, centerInMainView.x - rotationPoint.x, centerInMainView.y-rotationPoint.y, 0.0);
            
            layoutAttributes.transform3D = transform;
            
            // right card is always on top
            layoutAttributes.zIndex = layoutAttributes.indexPath.item;
            
            [modifiedLayoutAttributesArray addObject:layoutAttributes];
        }
    }];
    return array;
}

- (float)remapNumbersToRange:(float)inputNumber fromMin:(float)fromMin fromMax:(float)fromMax toMin:(float)toMin toMax:(float)toMax {
    return (inputNumber - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
}

-(CGPoint)calculateTranslateBy:(CGFloat)horizontalCenter attribs:(UICollectionViewLayoutAttributes *) layoutAttributes {
    float translateByY = -layoutAttributes.frame.size.height/2.0f;
    float distanceFromCenter = layoutAttributes.center.x - horizontalCenter;
    float translateByX = 0.0f;
    
    if (distanceFromCenter < 1){
        translateByX = -1 * distanceFromCenter;
    }else{
        translateByX = -1 * distanceFromCenter;
    }
    return CGPointMake(distanceFromCenter, translateByY);
}


-(float)calculateRotationFromViewPortDistance:(float)x center:(float)horizontalCenter {
    
    float rotateByDegrees = [self remapNumbersToRange:x fromMin:-122 fromMax:258 toMin:-35 toMax:35];
    return rotateByDegrees;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {

    CGFloat offsetAdjustment = CGFLOAT_MAX;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.f) - LEFT_INSET;

    CGRect visibleRect = CGRectMake(proposedContentOffset.x, 0.0f, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);

    NSArray *array = [super layoutAttributesForElementsInRect:visibleRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat distanceFromCenter = layoutAttributes.center.x - horizontalCenter;
        if (ABS(distanceFromCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = distanceFromCenter;
        }
    }

    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
