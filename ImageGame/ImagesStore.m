//
//  ImagesStore.m
//  ImageGame
//
//  Created by Sidhartha Topcharla on 11/13/16.
//  Copyright © 2016 Sidhartha Topcharla. All rights reserved.
//

#import "ImagesStore.h"


static NSString *const flickrAPIFeedsURL = @"https://api.flickr.com/services/feeds/photos_public.gne?format=json";
static NSInteger TotalImageCount = 9;

@interface ImagesStore(){
//    dispatch_block_t downloadGroup;
}

@property (strong, nonatomic) NSMutableArray *flickerFeedsArray;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) dispatch_group_t completionGroup;

@end

@implementation ImagesStore

#pragma mark Singleton implementation

+ (ImagesStore *) sharedStore
{
    static ImagesStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
        sharedStore.downloadQueue = [[NSOperationQueue alloc] init];
        sharedStore.photosCache = [[NSCache alloc] init];
        sharedStore.flickerFeedsArray = [[NSMutableArray alloc] init];
    });
    return sharedStore;
}

#pragma mark - Flickr API Calls

- (void)getFlickrPhotoFeedsWithCompletion:(void(^)(BOOL success))completion {
    
    NSURL *requestURL = [NSURL URLWithString:flickrAPIFeedsURL];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error){
            NSError *dataError = nil;
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dataString = [dataString stringByReplacingOccurrencesOfString:@"jsonFlickrFeed(" withString:@""];
            dataString = [dataString stringByReplacingOccurrencesOfString:@"})" withString:@"}"];
            NSData *refinedData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            
            id responseObject = [NSJSONSerialization JSONObjectWithData:refinedData options:0 error:&dataError];
            
            if(!responseObject || dataError){
                // Serialization Error Occured
                dispatch_async(dispatch_get_main_queue(),^{
                    if(completion){
                        completion(NO);
                    }
                });
            } else if([responseObject isKindOfClass:[NSDictionary class]]){
                NSArray *array = [responseObject valueForKeyPath:@"items.media.m"];
                
                for (int i=0; i<TotalImageCount; i++) {
                    [self.flickerFeedsArray addObject:[array objectAtIndex:i]];
                }
                
                [self downloadPhotosBatch:self.flickerFeedsArray];
                dispatch_async(dispatch_get_main_queue(),^{
                    if(completion){
                        completion(YES);
                    }
                });
            } else {
                // Flickr API Data Type Error
                dispatch_async(dispatch_get_main_queue(),^{
                    if(completion){
                        completion(NO);
                    }
                });
            }
        } else {
            // Flickr API Error Occured
            dispatch_async(dispatch_get_main_queue(),^{
                if(completion){
                    completion(NO);
                }
            });
        }
        
    }];
    
    [task resume];
}


#pragma mark - Download photos from URL

- (void)downloadPhotosBatch:(NSArray *)photosArray {
    
    /*
     * Add the Batch to DownloadQueue
     * Save Downloaded Photo into Cache
     * Try Updating the UI if corresponding UIIMageView loaded
     */
    self.completionGroup = dispatch_group_create();
    for (NSString* photoURL in photosArray) {
        dispatch_group_enter(self.completionGroup);
        NSBlockOperation *downloadOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]];
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            [self.photosCache setObject:downloadedImage forKey:photoURL];
            // Image downloaded, Notify for UI Update if Needed.
            dispatch_group_leave(self.completionGroup);
        }];
        
        [self.downloadQueue addOperation:downloadOperation];
    }
    
    dispatch_group_notify(self.completionGroup, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(allRequiredImagesDownload:)]) {
            [self.delegate allRequiredImagesDownload:(int)self.flickerFeedsArray.count];
        }
    });
}


- (NSArray*) getAllImages{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(NSString *photoURL in self.flickerFeedsArray){
        if([self.photosCache objectForKey:photoURL]){
            [array addObject:[self.photosCache objectForKey:photoURL]];
        }
    }
    return array;
}

- (UIImage*) getImageAtIndex:(int)index{
    if (index<_flickerFeedsArray.count) {
        return [self.photosCache objectForKey:[self.flickerFeedsArray objectAtIndex:index]];
    }
    return nil;
}

@end
