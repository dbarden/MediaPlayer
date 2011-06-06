//
//  RootViewController.h
//  MediaPlayer
//
//  Created by Daniel Barden on 5/31/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface RootViewController : UITableViewController {
    NSDictionary *artists;
}

@property (nonatomic, retain) NSDictionary *artists;
@end
