//
//  DEViewController.m
//  dragAndDropExample
//
//  Created by Mayank Kumar on 3/6/14.
//  Copyright (c) 2014 Mayank Kumar. All rights reserved.
//

#import "DEViewController.h"
#import "DECollectionViewCell.h"
#import "DECellData.h"
#import "UIView+ShakeAnimation.h"

const CGFloat kMinPanToMoveCell = 50;
const CGFloat kMinPanToDropCellToTopCV = kMinPanToMoveCell+100;

const NSString *collectionCellIdentity = @"aDECollectionCell";

@interface DEViewController ()
    <UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIDynamicAnimatorDelegate,
    UIGestureRecognizerDelegate,
    UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentCellHeader;
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

@property (nonatomic) NSIndexPath *placeHolderCellIndex;
@property (nonatomic) BOOL removedFromTop;
@end

@implementation DEViewController
- (void) doInits {
    self.bottomCVDataSource= [NSMutableArray arrayWithArray:@[[[DECellData alloc] initWithString:@"A"],
                                                              [[DECellData alloc] initWithString:@"B"],
                                                              [[DECellData alloc] initWithString:@"C"],
                                                              [[DECellData alloc] initWithString:@"D"],
                                                              [[DECellData alloc] initWithString:@"E"],
                                                              [[DECellData alloc] initWithString:@"F"],
                                                              [[DECellData alloc] initWithString:@"G"],
                                                              [[DECellData alloc] initWithString:@"H"],
                                                              [[DECellData alloc] initWithString:@"I"],
                                                              [[DECellData alloc] initWithString:@"J"],
                                                              [[DECellData alloc] initWithString:@"K"]]];
    self.topCVDataSource= [NSMutableArray arrayWithArray:@[[[DECellData alloc] initWithString:@"1"],
                                                           [[DECellData alloc] initWithString:@"2"],
                                                           [[DECellData alloc] initWithString:@"3"],
                                                           [[DECellData alloc] initWithString:@"4"],
                                                           [[DECellData alloc] initWithString:@"5"],
                                                           [[DECellData alloc] initWithString:@"6"]]];
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
    
    self.bottomCollectionView.clipsToBounds = NO;
    self.topCollectionView.clipsToBounds = NO;
    self.currentCellHeader.text = [NSString stringWithFormat:@"This is data for cell \"%@\"", ((DECellData*)[self.bottomCVDataSource firstObject]).cellName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bottomCollectionView) {
        NSIndexPath *centerCellIndex = [self.bottomCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.bottomCollectionView.bounds) , CGRectGetMidY(self.bottomCollectionView.bounds))];
        self.currentCellHeader.text = [NSString stringWithFormat:@"This is data for cell \"%@\"", ((DECellData*)[self.bottomCVDataSource objectAtIndex:centerCellIndex.row]).cellName];
    }
}

#pragma mark - UICollectionViewDataSource Methods
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
        cell.imageView = ((DECellData*)self.bottomCVDataSource[indexPath.item]).cellImageView;
        UIPanGestureRecognizer *panGestureRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnBottomCell:)];
        panGestureRecog.delegate = self;
        cell.gestureRecognizer = panGestureRecog;
        return cell;
    } else if (collectionView == self.topCollectionView){
        DECollectionViewCell *cell = (DECollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[collectionCellIdentity copy] forIndexPath:indexPath];
        cell.imageView = ((DECellData*)self.topCVDataSource[indexPath.item]).cellImageView;
        UIPanGestureRecognizer *panGestureRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnTopCell:)];
        panGestureRecog.delegate = self;
        cell.gestureRecognizer = panGestureRecog;
        if (self.placeHolderCellIndex && indexPath.row == self.placeHolderCellIndex.row) {
            cell.isPlaceHolder = YES;
        } else {
            cell.isPlaceHolder = NO;
        }
        return cell;
    }
    return nil;
}

#pragma  mark - Gesture Recognizer Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) handlePanOnTopCell:(UIPanGestureRecognizer*)gesture {
    CGPoint touchLocation = [gesture locationInView:self.view];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //Remove all old behaviors
        [self.animator removeAllBehaviors];
        //Save initial center for snap
        self.pannedViewInitialCenter = gesture.view.center;
        //Save index
        self.currentSelectedCellIndexPath = [self.topCollectionView indexPathForCell:(DECollectionViewCell*)gesture.view];
        //Save data
        self.currentSelectedCellData = [self.topCVDataSource objectAtIndex:self.currentSelectedCellIndexPath.row];
        //Get initial touch location
        self.panInitialTouchLocation = touchLocation;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        //NSLog(@"Moving cell #%i, cell=%@", self.currentSelectedCellIndexPath.row, gesture.view);
        CGFloat panAmount = fabs(touchLocation.y-self.panInitialTouchLocation.y);
        if (panAmount >= kMinPanToMoveCell) {
            if (!self.attachmentBehavior) {
                //Create snapshot we will attach to behavior
                self.currentSelectedCellSnapshot = [gesture.view snapshotViewAfterScreenUpdates:NO];
                self.currentSelectedCellSnapshot.frame = [self.view convertRect:gesture.view.frame fromView:gesture.view.superview];
                self.currentSelectedCellSnapshot.transform = gesture.view.transform;
                [self.view addSubview:self.currentSelectedCellSnapshot];
                
                //Disable scroll
                self.topCollectionView.scrollEnabled = NO;
                
                //Create attachment behavior, from view's center to the touch location
                self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.currentSelectedCellSnapshot offsetFromCenter:UIOffsetMake(0, 0) attachedToAnchor:[gesture locationInView:self.view]];
                //Add behavior to animator
                [self.animator addBehavior:self.attachmentBehavior];
                
                //Covert cell to placehold cell
                DECollectionViewCell *cell = (DECollectionViewCell*)gesture.view;
                cell.isPlaceHolder = YES;
                self.placeHolderCellIndex = self.currentSelectedCellIndexPath;
            }
            self.attachmentBehavior.anchorPoint = [gesture locationInView:self.view];
        }
        if (panAmount >= kMinPanToDropCellToTopCV) {
            [self removePlaceHolderFromTopCollection];
            self.removedFromTop = YES;
        } else if (self.removedFromTop) {
            [self insertPlaceHolderToTopCollection];
            self.removedFromTop = NO;
        }
    } else {
        if (self.attachmentBehavior.dynamicAnimator) {
            [self.animator removeAllBehaviors];
            self.attachmentBehavior = nil;
            
            CGFloat panAmount = fabs(touchLocation.y-self.panInitialTouchLocation.y);
            if (panAmount < kMinPanToDropCellToTopCV) {
                //Add back to Top collection view with snap behavior
                DECollectionViewCell *placeHolderCell = (DECollectionViewCell*)[self.topCollectionView cellForItemAtIndexPath:self.placeHolderCellIndex];
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.currentSelectedCellSnapshot snapToPoint:[self.view convertPoint:placeHolderCell.center fromView:placeHolderCell.superview]];
                [self.animator addBehavior:snap];
                [self performSelector:@selector(addCellToTopCollectionView) withObject:nil afterDelay:.3];
            } else {
                //Add to the bottom collection view
                self.currentSelectedCellIndexPath = [self dropIndexForCollectionView:self.bottomCollectionView];
                DECollectionViewCell *placeHolderCell = (DECollectionViewCell*)[self.bottomCollectionView cellForItemAtIndexPath:self.currentSelectedCellIndexPath];
                if (placeHolderCell) {
                    [UIView animateWithDuration:.33 animations:^{
                        CGRect frame = self.currentSelectedCellSnapshot.frame;
                        CGSize bottomCVCellSize = [self.bottomCollectionView cellForItemAtIndexPath:self.currentSelectedCellIndexPath].frame.size;
                        frame = CGRectInset(frame, frame.size.width-bottomCVCellSize.width, frame.size.height-bottomCVCellSize.height);
                        self.currentSelectedCellSnapshot.frame = frame;
                    }];
                }
                CGPoint dropPoint = placeHolderCell ? [self.view convertPoint:placeHolderCell.center fromView:placeHolderCell.superview] : CGPointMake(self.bottomCollectionView.center.x, self.bottomCollectionView.center.y);
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.currentSelectedCellSnapshot snapToPoint:dropPoint];
                [self.animator addBehavior:snap];
                [self performSelector:@selector(addDeletedCellBackToBottomCollectionView) withObject:nil afterDelay:.3];
            }
            self.removedFromTop = NO;
            self.topCollectionView.scrollEnabled = YES;
        }
    }
}

- (void) handlePanOnBottomCell:(UIPanGestureRecognizer*)gesture {
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
        if (panAmount >= kMinPanToMoveCell) {
            if (!self.attachmentBehavior) {
                //Create snapshot we will attach to behavior
                self.currentSelectedCellSnapshot = [gesture.view snapshotViewAfterScreenUpdates:NO];
                self.currentSelectedCellSnapshot.frame = [self.view convertRect:gesture.view.frame fromView:gesture.view.superview];
                self.currentSelectedCellSnapshot.transform = gesture.view.transform;
                [self.view addSubview:self.currentSelectedCellSnapshot];
                
                //Don't wait for the collection view to remove it. Hide it right away.
                gesture.view.hidden = YES;
                //Create attachment behavior, from view's center to the touch location
                self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.currentSelectedCellSnapshot offsetFromCenter:UIOffsetMake(0, 0) attachedToAnchor:[gesture locationInView:self.view]];
                //Add behavior to animator
                [self.animator addBehavior:self.attachmentBehavior];
                //Disable scroll
                self.bottomCollectionView.scrollEnabled = NO;
                //Remove cell from bottom collection view
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
                DECollectionViewCell *placeHolderCell = (DECollectionViewCell*)[self.topCollectionView cellForItemAtIndexPath:self.placeHolderCellIndex];
                if (placeHolderCell) {
                    [UIView animateWithDuration:.33 animations:^{
                        CGRect frame = self.currentSelectedCellSnapshot.frame;
                        CGSize topCVCellSize = [self.topCollectionView cellForItemAtIndexPath:self.placeHolderCellIndex].frame.size;
                        frame = CGRectInset(frame, frame.size.width-topCVCellSize.width, frame.size.height-topCVCellSize.height);
                        self.currentSelectedCellSnapshot.frame = frame;
                    }];
                }
                CGPoint dropPoint = placeHolderCell ? [self.view convertPoint:placeHolderCell.center fromView:placeHolderCell.superview] : CGPointMake(self.topCollectionView.center.x, self.topCollectionView.center.y);
                UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.currentSelectedCellSnapshot snapToPoint:dropPoint];
                [self.animator addBehavior:snap];
                [self performSelector:@selector(addCellToTopCollectionView) withObject:nil afterDelay:.3];
            }
            self.bottomCollectionView.scrollEnabled = YES;
        }
    }
}

#pragma mark - Collection View Data Source Manipulaion
- (void) insertPlaceHolderToTopCollection {
    if (!self.placeHolderCellIndex) {
        self.placeHolderCellIndex = [self dropIndexForCollectionView:self.topCollectionView];
        [self.topCollectionView performBatchUpdates:^{
            [self.topCVDataSource insertObject:self.currentSelectedCellData atIndex:self.placeHolderCellIndex.row];
            [self.topCollectionView insertItemsAtIndexPaths:@[self.placeHolderCellIndex]];
        }completion:^(BOOL finished){
            [self shakeCells];
        }];
    }
}

- (void) removePlaceHolderFromTopCollection {
    if (self.placeHolderCellIndex) {
        NSIndexPath *tempIndex = [self.placeHolderCellIndex copy];
        self.placeHolderCellIndex = nil;
        [self.topCollectionView performBatchUpdates:^{
            [self.topCVDataSource removeObjectAtIndex:tempIndex.row];
            [self.topCollectionView deleteItemsAtIndexPaths:@[tempIndex]];
        }completion:^(BOOL finished){
            [self stopCellShake];
        }];
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
    if (self.placeHolderCellIndex) {
        DECollectionViewCell *placeHolderCell = (DECollectionViewCell*)[self.topCollectionView cellForItemAtIndexPath:self.placeHolderCellIndex];
        self.placeHolderCellIndex = nil;
        placeHolderCell.isPlaceHolder = NO;
        [self.currentSelectedCellSnapshot removeFromSuperview];
        //Clean up
        self.currentSelectedCellIndexPath = nil;
        self.currentSelectedCellSnapshot = nil;
        [self stopCellShake];
    }
}

- (NSIndexPath*) dropIndexForCollectionView:(UICollectionView*)cv {
    int count = [[cv indexPathsForVisibleItems] count];
    if ( count < 2) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    int min = INT32_MAX;
    for (NSIndexPath *index in [cv indexPathsForVisibleItems]) {
        min = MIN(min, index.row);
    }
    return [NSIndexPath indexPathForRow:min+1 inSection:0];
}

#pragma mark - Shake Animation Methods
- (void) shakeCells {
    if (self.placeHolderCellIndex) {
        //Shake cells
        NSArray *cells = [self.topCollectionView visibleCells];
        for (DECollectionViewCell *cell in cells) {
            if (!cell.isPlaceHolder) {
                [cell startShakeAnimation];
            }
        }
    }
}

- (void) stopCellShake {
    if (!self.placeHolderCellIndex) {
        //Stop Shake
        NSArray *cells = [self.topCollectionView visibleCells];
        for (DECollectionViewCell *cell in cells) {
            [cell stopShakeAnimation];
        }
    }
}

@end
