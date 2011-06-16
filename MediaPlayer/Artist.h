//
//  Artist.h
//  MediaPlayer
//
//  Created by Daniel Barden on 6/4/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Artist : NSObject {
    NSString *_name;
    NSString *_sortableName;
    NSString *_mbid;
    NSString *_biography;
    NSDictionary *_thumbs;
    UIImage *_smallImageThumb;
    
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSString *mbid;
@property (nonatomic, copy) NSDictionary *thumbs;
@property (nonatomic, copy) UIImage *smallImageThumb;

- (NSString *)sortableName;
- (NSString *)comparableName:(NSString *)str;
@end
