//
//  Demo4TabbarController.m
//  RSCustomTabbarController
//
//  Created by Ratul Sharker on 10/8/16.
//  Copyright © 2016 funtoos. All rights reserved.
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "Demo4TabbarController.h"
#import "Demo4TabbarCell.h"
#import "BrowserChildVC.h"
#import "AppDelegate.h"
#import "FadingTabbarTransitionAnimation.h"

#define TABBAR_CELL_REUSE_ID    @"tabbar.reuse.cell.id"


//
//  used in info dictionary
//
#define TABBAR_CELL_LABEL_KEY       @"tabbar.label.key"
#define TABBAR_CELL_SELECTED_KEY    @"tabbar.selected.key"

#define TABBAR_MIN_WIDTH        65
#define TABBAR_MAX_WIDTH        90

typedef void(^collectionViewConstraintUpdated)();

@interface Demo4TabbarController () <   UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout,
                                        Demo4TabbarCellDelegate>

@end

@implementation Demo4TabbarController
{
    
    NSMutableArray <NSMutableDictionary*>  *tabbarsInfo;
    NSMutableArray <UIViewController*>     *mutableViewControllers;
    
    
    IBOutlet UIButton *mViewAddBtn;
    IBOutlet UICollectionView *mViewTabbarCollectionView;
    IBOutlet NSLayoutConstraint *mViewCollectionViewWidth;
    
    UIStoryboard *broswerStoryboard;
}


- (void)viewDidLoad {
    tabbarsInfo = [[NSMutableArray alloc] init];

    
    
    mViewTabbarCollectionView.allowsSelection = YES;
    mViewTabbarCollectionView.allowsMultipleSelection = NO;
    
    broswerStoryboard = [UIStoryboard storyboardWithName:@"childs" bundle:[NSBundle mainBundle]];
    mutableViewControllers = [[NSMutableArray alloc] init];
    
    mViewAddBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    super.transitionAnimationDelegate = [[FadingTabbarTransitionAnimation alloc] init];
    
    [super viewDidLoad];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //
    //  set the collection view's layout here
    //
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)mViewTabbarCollectionView.collectionViewLayout;
    mViewTabbarCollectionView.contentInset = UIEdgeInsetsZero;
    
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    
    mViewTabbarCollectionView.collectionViewLayout = layout;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark IBActions
- (IBAction)onAddActionBtnPressed:(id)sender
{
    
    NSInteger count = tabbarsInfo.count;
    [tabbarsInfo addObject:[[NSMutableDictionary alloc] initWithDictionary:@{
                                                                             TABBAR_CELL_LABEL_KEY : [NSNumber numberWithInteger:count],
                                                                             TABBAR_CELL_SELECTED_KEY : [NSNumber numberWithBool:YES]
    
                                                                             }]];
    
    BrowserChildVC *browserVC = [broswerStoryboard instantiateViewControllerWithIdentifier:@"browser_child_vc"];
    [mutableViewControllers addObject:browserVC];
    [super setViewControllers:mutableViewControllers];
    
    
    [self refreshCollectionViewSize:^{
        
        NSIndexPath *newItemIndexPath = [NSIndexPath indexPathForRow:tabbarsInfo.count-1 inSection:0];
        
        [mViewTabbarCollectionView insertItemsAtIndexPaths:@[newItemIndexPath]];
        [mViewTabbarCollectionView scrollToItemAtIndexPath:newItemIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        
        [super setSelectedViewCotnrollerAtIndex:newItemIndexPath.row];
    }];
}

- (IBAction)onBackPressed:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = [appDelegate getCurrentNavigationController];
    
    [navController popViewControllerAnimated:YES];
}




#pragma mark RSCustomTabbarImplementationDelegate
-(CGFloat)heightForTabbarController:(RSCustomTabbarController*)tabbarController
{
    return 38;
}
-(void)newSelectedTabbarIndex:(NSUInteger)newSelectedIndex whereOldIndexWas:(NSUInteger)oldSelectedIndex
{
    if(newSelectedIndex == oldSelectedIndex)
    {
        //it's for the first item
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:newSelectedIndex inSection:0];
        [self selectCellAtIndexPath:selectedIndexPath forCollectionView:mViewTabbarCollectionView];
    }
    else
    {
        
        NSLog(@"selected %ld unselected %ld", newSelectedIndex, oldSelectedIndex);
        
        //subsequent calls
        NSIndexPath *unselectedIndexPath = [NSIndexPath indexPathForRow:oldSelectedIndex inSection:0];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:newSelectedIndex inSection:0];
        
        [self selectCellAtIndexPath:selectedIndexPath forCollectionView:mViewTabbarCollectionView];
        [self unselectCellAtIndexPath:unselectedIndexPath forCollectionView:mViewTabbarCollectionView];
        
        
    }
}


#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tabbarsInfo.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Demo4TabbarCell *cell = (Demo4TabbarCell*)[collectionView dequeueReusableCellWithReuseIdentifier:TABBAR_CELL_REUSE_ID
                                                                           forIndexPath:indexPath];
    
    NSDictionary *tabbarInfo = tabbarsInfo[indexPath.row];
    
    NSNumber *number = tabbarInfo[TABBAR_CELL_LABEL_KEY];
    NSNumber *isSelected = tabbarInfo[TABBAR_CELL_SELECTED_KEY];
    
    cell.mViewLabel.text = [NSString stringWithFormat:@"%ld", number.integerValue];
    
    if([isSelected boolValue])
    {
        [cell setSelectedImage];
    }
    else
    {
        [cell setNormalImage];
    }
    
    cell.delegate = self;
    return cell;
}

#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super setViewControllers:mutableViewControllers];
    [super setSelectedViewCotnrollerAtIndex:indexPath.row];
}

#pragma mark UICollectionViewFlowLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat perItemWidth = collectionView.bounds.size.width / tabbarsInfo.count;
    
    if(perItemWidth > TABBAR_MAX_WIDTH)
    {
        perItemWidth = TABBAR_MAX_WIDTH;
    }
    
    if(perItemWidth < TABBAR_MIN_WIDTH)
    {
        perItemWidth = TABBAR_MIN_WIDTH;
    }
    
    return CGSizeMake(perItemWidth,
                      collectionView.bounds.size.height);
    
}


#pragma mark Demo4TabbarCellDelegate

-(void)crossPressedForDemo4TabbarCell:(Demo4TabbarCell*)cell
{
    NSIndexPath *indexPath = [mViewTabbarCollectionView indexPathForCell:cell];
    NSInteger index = indexPath.row;
    
    //
    [mViewTabbarCollectionView scrollToItemAtIndexPath:indexPath
                                      atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                              animated:YES];
    
    //
    UIViewController *targetViewController = mutableViewControllers[index];
    [super removeViewControllerFromContainer:targetViewController];
    
    //
    [mutableViewControllers removeObjectAtIndex:index];
    [tabbarsInfo removeObjectAtIndex:index];
    [mViewTabbarCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    [super setViewControllers:mutableViewControllers];
    
    [self refreshCollectionViewSize:nil];
}


#pragma mark private methods
-(void)selectCellAtIndexPath:(NSIndexPath*)indexPath forCollectionView:(UICollectionView*)collectionView
{
    //
    //  change the data to selected
    //
    NSMutableDictionary *tabbarInfo = tabbarsInfo[indexPath.row];
    tabbarInfo[TABBAR_CELL_SELECTED_KEY] = [NSNumber numberWithBool:YES];
    
    Demo4TabbarCell *cell = (Demo4TabbarCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelectedImage];
}

-(void)unselectCellAtIndexPath:(NSIndexPath*)indexPath forCollectionView:(UICollectionView*)collectionView
{
    //
    //  change the data to selected
    //
    NSMutableDictionary *tabbarInfo = tabbarsInfo[indexPath.row];
    tabbarInfo[TABBAR_CELL_SELECTED_KEY] = [NSNumber numberWithBool:NO];
    
    Demo4TabbarCell *cell = (Demo4TabbarCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setNormalImage];
}

-(void)refreshCollectionViewSize:(collectionViewConstraintUpdated)completion
{
    mViewCollectionViewWidth.constant = tabbarsInfo.count * TABBAR_MAX_WIDTH;

            [self.view updateConstraints];
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
    
            } completion:^(BOOL finished) {
                if(completion)
                    completion();
            }];
}

@end
