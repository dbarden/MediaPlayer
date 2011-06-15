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
    
    ASINetworkQueue *_queue;
}

@property (nonatomic, retain) ASINetworkQueue *queue;
@property (nonatomic, retain) id <DownloadManagerDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary *artistIndexPathDict;

- (void)processArtistInfo:(ASIHTTPRequest*)request;
- (void)processArtistThumbImage:(ASIHTTPRequest *)request;
- (void)downloadArtistInfo:(Artist*)artist withIndexPath:(NSIndexPath *)artistIndexPath;
- (void)downloadAlbumInfo:(Album*)album;

@end

@protocol DownloadManagerDelegate

- (void)didFinishArtistDownload:(Artist *)artist forIndexPath:(NSIndexPath *)indexPath;
@end