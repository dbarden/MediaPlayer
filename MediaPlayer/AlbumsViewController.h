//
//  AlbumsViewController.h
//  MediaPlayer
//
//  Created by Daniel Barden on 6/3/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlbumsViewController : UITableViewController {
    NSString *artist;
    NSArray *albums;
}

@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSArray *albums;
@end
