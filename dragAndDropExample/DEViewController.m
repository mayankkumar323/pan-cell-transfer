//
//  DEViewController.m
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "DEViewController.h"
#import "DECollectionViewCell.h"
#import "UIImage+imageCreator.h"

const CGFloat kMinPanToMoveCell = 50;
const CGFloat kMinPanToDropCellToTopCV = kMinPanToMoveCell+100;

const NSString *collectionCellIdentity = @"aDECollectionCell";

@interface DEViewController ()
    <UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIDynamicAnimatorDelegate,
    UIGestureRecognizerDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *bottomCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *topCollectionView;
@property (nonatomic, strong) NSMutableArray * bottomCVDataSource;
@property (nonatomic, strong) NSMutableArray * topCVDataSource;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic) CGPoint panInitialTouchLocation;
@property (nonatomic) CGPoint pannedViewInitialCenter;

@property (nonatomic, strong) NSIndexPath *currentSelectedCellIndexPath;
@property (nonatomic, strong) UIView *currentSelectedCellSnapshot;
@property (nonatomic, strong) UIImageView *currentSelectedCellData;

@property (nonatomic) NSIndexPath *cellDropIndex;
@end

@implementation DEViewController
- (void) doInits {
    CGSize size = CGSizeMake(200, 200);
    self.bottomCVDataSource= [NSMutableArray arrayWithArray:@[[[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"A"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"B"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"C"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"D"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"E"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"F"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"G"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"H"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"I"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"J"]],
                                                              [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"K"]]]];
    self.topCVDataSource= [NSMutableArray arrayWithArray:@[[[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"1"]],
                                                           [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"2"]],
                                                           [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"3"]],
                                                           [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"4"]],
                                                           [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"5"]],
                                                           [[UIImageView alloc] initWithImage:[UIImage imageOfSize:size withString:@"6"]]]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self doInits];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInits];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.bottomCollectionView registerClass:[DECollectionViewCell class] forCellWithReuseIdentifier:[collectionCellIdentity copy]];
    [self.topCollectionView registerClass:[DECollectionViewCell class] forCellWithReuseIdentifier:[collectionCellIdentity copy]];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;
    
    self.bottomCollectionView.clipsToBounds = NO;
    self.topCollectionView.clipsToBounds = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.bottomCollectionView) {
        return [self.bottomCVDataSource count];
    }else if (collectionView == self.topCollectionView){
        return [self.topCVDataSource count];
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.bottomCollectionView) {
        DECollectionViewCell *cell = (DECollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[collectionCellIdentity copy] forIndexPath:indexPath];
        cell.imageView = self.bottomCVDataSource[indexPath.item];
        UIPanGestureRecognizer *panGestureRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnCell:)];
        panGestureRecog.delegate = self;
        cell.gestureRecognizer = panGestureRecog;
        return cell;
    } else if (collectionView == self.topCollectionView){
        DECollectionViewCell *cell = (DECollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[collectionCellIdentity copy] forIndexPath:indexPath];
        cell.imageView = self.topCVDataSource[indexPath.item];
        if (self.cellDropIndex && indexPath.row == self.cellDropIndex.row) {
            cell.isPlaceHolder = YES;
        }
        return cell;
    }
    return nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma  mark - Handle Pan
- (void) handlePanOnCell:(UIPanGestureRecognizer*)gesture {
    CGPoint touchLocation = [gesture locationInView:self.view];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //Remove all old behaviors
        [self.animator removeAllBehaviors];
        //Save initial center for snap
        self.pannedViewInitialCenter = gesture.view.center;
        //Save index
        self.currentSelectedCellIndexPath = [self.bottomCollectionView indexPathForCell:(DECollectionViewCell*)gesture.view];
        //Save data
        self.currentSelectedCellData = [self.bottomCVDataSource objectAtIndex:self.currentSelectedCellIndexPath.row];
        //Get initial touch location
        self.panInitialTouchLocation = touchLocation;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Moving cell #%i, cell=%@", self.currentSelectedCellIndexPath.row, gesture.view);
        CGFloat panAmount = fabs(touchLocation.y-self.panInitialTouchLocation.y);
        if (panAmount > kMinPanToMoveCell) {
            if (!self.attachmentBehavior) {
                //Create snapshot we will attach to behavior
                self.currentSelectedCellSnapshot = [gesture.view snapshotViewAfterScreenUpdates:NO];
                self.currentSelectedCellSnapshot.frame = [self.view convertRect:gesture.view.frame fromView:gesture.view.superview];
                self.currentSelectedCellSnapshot.transform = gesture.view.transform;
                self.currentSelectedCellSnapshot.frame = [self.view convertRect:gesture.view.frame fromView:gesture.view.superview];
                [self.view addSubview:self.currentSelectedCellSnapshot];
                //Don't wait for the collection view to remove it. Hide it right away.
                gesture.view.hidden = YES;
                //Create attachment behavior, from view's center to the touch location
                self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.currentSelectedCellSnapshot offsetFromCenter:UIOffsetMake(0, 0) attachedToAnchor:[gesture locationInView:self.view]];
                //Add behavior to animator
                [self.animator addBehavior:self.attachmentBehavior];
                //Disable scroll
                self.bottomCollectionView.scrollEnabled = NO;
                //Remove cell from collection view
                [self.bottomCollectionView performBatchUpdates:^{
                    [self.bottomCVDataSource removeObjectAtIndex:self.currentSelectedCellIndexPath.row];
                    [self.bottomCollectionView deleteItemsAtIndexPaths:@[self.currentSelectedCellIndexPath]];
                } completion: ^(BOOL finished){
                    gesture.view.hidden = NO;
                }];
            }
            self.attachmentBehavior.anchorPoint = [gesture locationInView:self.view];
        }
        if (panAmount >= kMinPanToDropCellToTopCV) {
            [self insertPlaceHolderToTopCollection];
        } else {
            [self removePlaceHolderFromTopCollection];
        }
    } else {
        if (self.attachmentBehavior.dynamicAnimator) {
            [self.animator removeAllBehaviors];
            self.attachmentBehavior = nil;
            
            CGFloat panAmount = fabs(touchLocation.y-self.panInitialTouchLocation.y);
            if (panAmount < kMinPanToDropCellToTopCV) {
                //Add back to bottom collection view with snap behavior
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.currentSelectedCellSnapshot snapToPoint:[self.view convertPoint:self.pannedViewInitialCenter fromView:gesture.view.superview]];
                [self.animator addBehavior:snap];
                [self performSelector:@selector(addDeletedCellBackToBottomCollectionView) withObject:nil afterDelay:.3];
            } else {
                //Add to the top collection view
                DECollectionViewCell *placeHolderCell = (DECollectionViewCell*)[self.topCollectionView cellForItemAtIndexPath:self.cellDropIndex];
                [UIView animateWithDuration:.33 animations:^{
                    CGRect frame = self.currentSelectedCellSnapshot.frame;
                    CGSize topCVCellSize = [self.topCollectionView cellForItemAtIndexPath:self.cellDropIndex].frame.size;
                    frame = CGRectInset(frame, frame.size.width-topCVCellSize.width, frame.size.height-topCVCellSize.height);
                    self.currentSelectedCellSnapshot.frame = frame;
                }];
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.currentSelectedCellSnapshot snapToPoint:[self.view convertPoint:placeHolderCell.center fromView:placeHolderCell.superview]];
                [self.animator addBehavior:snap];
                [self performSelector:@selector(addCellToTopCollectionView) withObject:nil afterDelay:.3];
            }
            self.bottomCollectionView.scrollEnabled = YES;
        }
    }
}

- (void) insertPlaceHolderToTopCollection {
    if (!self.cellDropIndex) {
        self.cellDropIndex = [NSIndexPath indexPathForRow:((NSIndexPath*)[[self.topCollectionView indexPathsForVisibleItems] objectAtIndex:1]).row inSection:0];
        [self.topCollectionView performBatchUpdates:^{
            [self.topCVDataSource insertObject:self.currentSelectedCellData atIndex:self.cellDropIndex.row];
            [self.topCollectionView insertItemsAtIndexPaths:@[self.cellDropIndex]];
        }completion:nil];
    }
}

- (void) removePlaceHolderFromTopCollection {
    if (self.cellDropIndex) {
        NSIndexPath *tempIndex = [self.cellDropIndex copy];
        self.cellDropIndex = nil;
        [self.topCollectionView performBatchUpdates:^{
            [self.topCVDataSource removeObjectAtIndex:tempIndex.row];
            [self.topCollectionView deleteItemsAtIndexPaths:@[tempIndex]];
        }completion:nil];
    }
}

- (void) addDeletedCellBackToBottomCollectionView {
    //Add cell back
    [self.bottomCollectionView performBatchUpdates:^{
        [self.bottomCVDataSource insertObject:self.currentSelectedCellData atIndex:self.currentSelectedCellIndexPath.row];
        [self.bottomCollectionView insertItemsAtIndexPaths:@[self.currentSelectedCellIndexPath]];
    } completion:^(BOOL finished){
        [self.currentSelectedCellSnapshot removeFromSuperview];
        //Adjust the z-index of the newly added cell
        DECollectionViewCell *cell = (DECollectionViewCell*)[self.bottomCollectionView cellForItemAtIndexPath:self.currentSelectedCellIndexPath];
        if (self.currentSelectedCellIndexPath.row > 0 && self.currentSelectedCellIndexPath.row < self.bottomCVDataSource.count-1) {
            //We don't care about cell at index 0, as that is already at the lowest z when added.
            NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:self.currentSelectedCellIndexPath.row-1 inSection:self.currentSelectedCellIndexPath.section];
            DECollectionViewCell *previousCell = (DECollectionViewCell*)[self.bottomCollectionView cellForItemAtIndexPath:previousIndex];
            [self.bottomCollectionView insertSubview:cell aboveSubview:previousCell];
        } else if (self.currentSelectedCellIndexPath.row == self.bottomCVDataSource.count-1) {
            //Last Item
            [self.bottomCollectionView bringSubviewToFront:cell];
        }
        //Clean up
        self.currentSelectedCellIndexPath = nil;
        self.currentSelectedCellSnapshot = nil;
        self.currentSelectedCellData = nil;
    }];
}

- (void) addCellToTopCollectionView {
    if (self.cellDropIndex) {
        DECollectionViewCell *placeHolderCell = (DECollectionViewCell*)[self.topCollectionView cellForItemAtIndexPath:self.cellDropIndex];
        self.cellDropIndex = nil;
        placeHolderCell.isPlaceHolder = NO;
        [self.currentSelectedCellSnapshot removeFromSuperview];
        //Clean up
        self.currentSelectedCellIndexPath = nil;
        self.currentSelectedCellSnapshot = nil;
    }
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    NSLog(@"paused");
}

@end
