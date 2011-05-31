//
//  MediaPlayerAppDelegate.h
//  MediaPlayer
//
//  Created by Daniel Barden on 5/31/11.
//  Copyright 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaPlayerAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
