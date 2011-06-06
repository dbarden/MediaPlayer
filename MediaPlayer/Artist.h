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
}

@property (nonatomic, copy) NSString *name;

- (NSString *)sortableName;
- (NSString *)comparableName:(NSString *)str;
@end
