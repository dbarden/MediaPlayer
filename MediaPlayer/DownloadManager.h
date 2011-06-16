//
//  DownloadManager.h
//  MediaPlayer
//
//  Created by Daniel Barden on 6/7/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Artist.h"
#import "Album.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@protocol DownloadManagerDelegate;
@class Artist;
@class Album;

@interface DownloadManager : NSObject {
    id <DownloadManagerDelegate> _delegate;
    
    NSMutableData *_activeDownload;
    NSURLConnection *_connection;
    NSMutableDictionary *_artistIndexPathDict;
    
    ASINetworkQueue *_infoQueue;
    ASINetworkQueue *_imageQueue;
}

@property (nonatomic, retain) ASINetworkQueue *infoQueue;
@property (nonatomic, retain) ASINetworkQueue *imageQueue;
@property (nonatomic, retain) id <DownloadManagerDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *artistIndexPathDict;

- (void)downloadArtistInfo:(NSArray *)artists;
- (void)downloadAlbumInfo:(Album*)album;
- (void)downloadArtistThumb:(Artist *)artist withIndexPath:(NSIndexPath *)indexPath;
- (void)processArtistInfo:(ASIHTTPRequest*)request;
- (void)processArtistThumbImage:(ASIHTTPRequest *)request;


- (NSString *)encodeIndexPath:(NSIndexPath *)indexPath;

@end

@protocol DownloadManagerDelegate
@optional

- (void)didDownloadArtistQueue:(NSArray *)artists;
- (void)didDownloadArtistThumb:(Artist *)artist forIndexPath:(NSIndexPath *)indexPath;

@end