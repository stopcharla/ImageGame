//
//  ImageCollectionViewCell.h
//  ImageGame
//
//  Created by Sidhartha Topcharla on 11/14/16.
//  Copyright © 2016 Sidhartha Topcharla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property BOOL isVisible;
@property BOOL isMatchedForUser;

@end
