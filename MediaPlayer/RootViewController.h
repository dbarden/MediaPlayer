//
//  RootViewController.h
//  MediaPlayer
//
//  Created by Daniel Barden on 5/31/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadManager.h"

#define kCoverKey 1
#define kNameKey 2

@interface RootViewController : UITableViewController <DownloadManagerDelegate> {
    NSDictionary *_artists;
    
    DownloadManager *_downloadManager;
}

@property (nonatomic, retain) NSDictionary *artists;
@property (nonatomic, retain) DownloadManager *downloadManager;

- (NSDictionary *)prepareData:(NSArray*)data;
- (void)didFinishArtistDownload:(Artist *)artist forIndexPath:(NSIndexPath *)indexPath;
@end
