//
//  ViewController.m
//  ImageGame
//
//  Created by Sidhartha Topcharla on 11/13/16.
//  Copyright © 2016 Sidhartha Topcharla. All rights reserved.
//

#import "ViewController.h"
#import "ImagesStore.h"
#import "ImageCollectionViewCell.h"

@interface ViewController () <ImagesDownloadDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSArray *imageArray;
    NSMutableArray *imagesMutableArray;
    BOOL shouldFlipAllImages;
    int indexOfImageToMatch;
}
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *displayImageView;
@property (weak, nonatomic) IBOutlet UILabel *findtheImageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    shouldFlipAllImages = NO;
    indexOfImageToMatch = -1;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
//    imageCount = 0;
    // Do any additional setup after loading the view, typically from a nib.
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    imagesMutableArray = [[NSMutableArray alloc] init];
    [[ImagesStore sharedStore] setDelegate:self];
    [[ImagesStore sharedStore] getFlickrPhotoFeedsWithCompletion:^(BOOL success) {
        if(!success){
            [self displayRetryMessage];
        }
    }];
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell"  bundle:nil] forCellWithReuseIdentifier:@"imageCellIdentifier"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayGameImages{
    [self.activityIndicator stopAnimating];
    imageArray = [[ImagesStore sharedStore] getAllImages];
    imagesMutableArray = [imageArray mutableCopy];
    [self.imagesCollectionView reloadData];
    [self performSelector:@selector(flipImagesForUser) withObject:nil afterDelay:5];
}


- (void) flipImagesForUser{
    shouldFlipAllImages = YES;
    [self.imagesCollectionView reloadData];
    [self beginGame];
}

- (void) beginGame{
    if (imagesMutableArray.count >0) {
        int randomIndex = arc4random()%imagesMutableArray.count;
        indexOfImageToMatch = randomIndex;
        [self displayImageToMatch];
    }
}

- (void) displayImageToMatch{
    NSLog(@"index to match:%d",indexOfImageToMatch);
    UIImage *image = [imagesMutableArray objectAtIndex:indexOfImageToMatch];
    self.displayImageView.image = image;
    [self.displayImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.displayImageView setHidden:NO];
    [self.findtheImageLabel setHidden:NO];
//    [self performSelector:@selector(hideGameImageForUser) withObject:nil afterDelay:2];
}

- (void) hideGameImageForUser{
    [self.displayImageView setHidden:YES];
    [self.findtheImageLabel setHidden:YES];
}

- (void) displayRetryMessage{
    
}

- (void)allRequiredImagesDownload:(int)count{
    if (count>0) {
        [self displayGameImages];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (imageArray.count < 10) {
        return imageArray.count;
    }else{
        return 9;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"imageCellIdentifier" forIndexPath:indexPath];
    UIImage *image = [imageArray objectAtIndex:indexPath.row];
    [cell.cellImageView setImage:image];
    cell.isVisible = !shouldFlipAllImages;
    cell.backgroundColor = [UIColor blueColor];
    if (!cell.isVisible) {
        [cell.cellImageView setHidden:YES];
    }
    
    cell.isVisible = NO;
    cell.isMatchedForUser = NO;
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize expectedSize = CGSizeMake(self.view.frame.size.width/3 - 10, 100);
    return expectedSize;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexOfImageToMatch >= 0) {
        ImageCollectionViewCell *cell = (ImageCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        if (!cell.isMatchedForUser) {
            if (cell.cellImageView.image == [imagesMutableArray objectAtIndex:indexOfImageToMatch]) {
                cell.isMatchedForUser = YES;
                [cell.cellImageView setHidden:NO];
                [self updateUnusedImages];
                [self hideGameImageForUser];
                [self performSelector:@selector(beginGame) withObject:nil afterDelay:0.5];
            }
        }
    }
}

- (void) updateUnusedImages{
    [imagesMutableArray removeObjectAtIndex:indexOfImageToMatch];
    indexOfImageToMatch = -1;
}

@end
