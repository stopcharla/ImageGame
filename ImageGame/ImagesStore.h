//
//  ImagesStore.h
//  ImageGame
//
//  Created by Sidhartha Topcharla on 11/13/16.
//  Copyright © 2016 Sidhartha Topcharla. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@protocol ImagesDownloadDelegate <NSObject>
- (void) allRequiredImagesDownload:(int)imagesCount;
@end


@interface ImagesStore : NSObject

@property NSCache *photosCache;
@property (nonatomic,weak)id<ImagesDownloadDelegate> delegate;

+ (ImagesStore *)sharedStore;

- (NSArray*) getAllImages;

- (void)getFlickrPhotoFeedsWithCompletion:(void(^)(BOOL success))completion;

@end
