//
//  Artist.m
//  MediaPlayer
//
//  Created by Daniel Barden on 6/4/11.
//  Copyright 2011 None. All rights reserved.
//

#import "Artist.h"


@implementation Artist

@synthesize name=_name;
@synthesize mbid=_mbid;
@synthesize thumbs=_thumbs;
@synthesize smallImageThumb=_smallImageThumb;

- (void) dealloc
{
    [_name release];
    [_sortableName release];
    [super dealloc];
}

- (void)setName:(NSString *)name
{
    [_name release];
    _name = [name copy];
    [_sortableName release];
    _sortableName = nil;
}

- (NSString *)sortableName
{
    if (_sortableName == nil){
        _sortableName = [[self comparableName:_name] retain];
    }
    return _sortableName;
}

- (NSString *)comparableName:(NSString *)str
{
    if (str == nil)
        return nil;
    else if ([str length] == 0)
        return [NSString stringWithString:str];
    
    NSCharacterSet *numberset = [NSCharacterSet decimalDigitCharacterSet];
    if ([str rangeOfCharacterFromSet:numberset options:0 range:NSMakeRange(0, 1)].location != NSNotFound)
        return [NSString stringWithString:str];
    
    NSRange range = NSMakeRange(0, [str length]);
    
    if ([str compare:@"a " options:(NSAnchoredSearch | NSCaseInsensitiveSearch) range:NSMakeRange(0, 2)] == NSOrderedSame)
        range.location = 2;
    if ([str compare:@"an " options:(NSAnchoredSearch | NSCaseInsensitiveSearch) range:NSMakeRange(0, 3)] == NSOrderedSame)
        range.location = 3;
    if ([str compare:@"the " options:(NSAnchoredSearch | NSCaseInsensitiveSearch) range:NSMakeRange(0, 4)] == NSOrderedSame)
        range.location = 4;
    
    range.length -= range.location;
    
    NSCharacterSet *lettersSet = [NSCharacterSet letterCharacterSet];
    NSUInteger letterOffset = [str rangeOfCharacterFromSet:lettersSet options:0 range:range].location;
    if (letterOffset == NSNotFound)
        return [NSString stringWithString:str];
    
    letterOffset -= range.location;
    range.location += letterOffset;
    range.length -=letterOffset;
    
    return [str substringWithRange:range];
}

@end
