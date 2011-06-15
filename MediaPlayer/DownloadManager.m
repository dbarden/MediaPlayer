//
//  DownloadManager.m
//  MediaPlayer
//
//  Created by Daniel Barden on 6/7/11.
//  Copyright 2011 None. All rights reserved.
//

#import "DownloadManager.h"
#import "JSON.h"

@implementation DownloadManager

@synthesize queue=_queue;
@synthesize delegate=_delegate;
@synthesize artistIndexPathDict=_artistiIndexPathDict;

- (id)init
{
    self = [super init];
    if (self) {
        _activeDownload = [NSMutableData data];
        _artistIndexPathDict = [[NSMutableDictionary alloc] init];
        
        ASINetworkQueue *tmpQueue = [[ASINetworkQueue alloc] init];
        [tmpQueue setDelegate:self];
        [tmpQueue setShouldCancelAllRequestsOnFailure:NO];
        [tmpQueue setRequestDidFailSelector:@selector(didRequestFailed:)];
        [tmpQueue setRequestDidFinishSelector:@selector(didRequestFinished:)];
        [tmpQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        self.queue = tmpQueue;
        [tmpQueue release];
    }
    
    return self;
}
- (NSString *)encodeIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    NSString *indexPathStr = [NSString stringWithFormat:@"%d_%d", section, row];
    return indexPathStr;
}

- (void)downloadArtistInfo:(Artist *)artist withIndexPath:(NSIndexPath *)indexPath
{
    static NSString *LastFMAPIKey = @"1ec0d3d1928d823fb7a58440c1d6ca65";
    NSString *searchString = [artist.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"SearchString %@", searchString);
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.search&artist=%@&api_key=%@&format=json", searchString, LastFMAPIKey]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"artist", @"type", @"info", @"phase", indexPath, @"indexPath", nil];

    [_artistIndexPathDict setObject:artist forKey:[self encodeIndexPath:indexPath]];
    NSLog(@"Hash %@, %@", [self encodeIndexPath:indexPath], _artistIndexPathDict);
    request.userInfo = dict;
    [dict release];
    
    [self.queue addOperation:request];
    [self.queue go];
    
}

- (void)downloadAlbumInfo:(Album *)album
{
    
}

///////////////////////////////////////////////////////////////////
- (void)didRequestFinished:(ASIHTTPRequest*)request
{
    _activeDownload = [NSMutableData data];

    NSString *type = [request.userInfo objectForKey:@"type"];
    if ([type isEqualToString:@"artist"]){
        if ([[request.userInfo objectForKey:@"phase"] isEqualToString:@"info"])
            [self processArtistInfo:request];
        else if ([[request.userInfo objectForKey:@"phase"] isEqualToString:@"image"])
            [self processArtistThumbImage:request];
    }
    
	NSLog(@"Request finished");

}

///////////////////////////////////////////////////////////////////
- (void)didRequestFailed:(ASIHTTPRequest*) request
{
    NSLog(@"Request Failed %@", [request.userInfo objectForKey:@"artist"]);
    
    NSIndexPath *indexPath = [request.userInfo objectForKey:@"indexPath"];
    Artist *artist = [_artistIndexPathDict objectForKey:indexPath];
    NSLog(@"Request failed: %@",artist.name);
    
    _activeDownload = [NSMutableData data];
    
	NSLog(@"Request failed");
    
}

///////////////////////////////////////////////////////////////////
- (void)queueFinished:(ASINetworkQueue *)queue
{

	NSLog(@"Queue finished");
}

//Receives the data and formats into jso and downloads the artist image
- (void)processArtistInfo:(ASIHTTPRequest *)request
{
    NSIndexPath *indexPath = [request.userInfo objectForKey:@"indexPath"];
    Artist *artist = [_artistIndexPathDict objectForKey:[self encodeIndexPath:indexPath]];
    NSLog(@"Artist Name %@", artist.name);
    
    NSString *responseString = [request responseString];
    NSDictionary *responseDict = [[[responseString JSONValue] objectForKey:@"results"] objectForKey:@"artistmatches"];
    NSDictionary *artistDict;
    if ([[responseDict objectForKey:@"artist"] isKindOfClass:[NSArray class]])
        artistDict = [[responseDict objectForKey:@"artist"] objectAtIndex:0];
    else
        artistDict = [responseDict objectForKey:@"artist"];
    
    artist.mbid = [artistDict objectForKey:@"mbid"];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *image in [artistDict objectForKey:@"image"]){
        [dict setObject:[image objectForKey:@"#text"] forKey:[image objectForKey:@"size"]];
    }
    artist.thumbs = dict;
    [dict release];
    
    //Triggers the image download
    NSURL *url = [[NSURL alloc] initWithString:[artist.thumbs objectForKey:@"medium"]];
    
    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:url];
    [imageRequest setDelegate:self];
    
    NSDictionary *userInfoDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"artist", @"type", @"image", @"phase", indexPath, @"indexPath", nil];
    imageRequest.userInfo = userInfoDict;
    [userInfoDict release];
    
    [[self queue] addOperation:imageRequest];
    [self.queue go];
}

- (void)processArtistThumbImage:(ASIHTTPRequest *)request
{
    NSLog(@"Got here");
    
    NSIndexPath *indexPath = [request.userInfo objectForKey:@"indexPath"];
    Artist *artist = [_artistIndexPathDict objectForKey:[self encodeIndexPath:indexPath]];
    artist.smallImageThumb = [UIImage imageWithData:[request rawResponseData]];
    [_delegate didFinishArtistDownload:artist forIndexPath:indexPath];
//    [_artistIndexPathDict removeObjectForKey:[self encodeIndexPath:indexPath]];    
}
@end
