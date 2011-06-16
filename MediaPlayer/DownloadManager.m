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

@synthesize infoQueue = _infoQueue;
@synthesize imageQueue = _imageQueue;
@synthesize delegate = _delegate;
@synthesize artistIndexPathDict = _artistIndexPathDict;

- (id)init
{
    self = [super init];
    if (self) {
        _activeDownload = [NSMutableData data];
        _artistIndexPathDict = [[NSMutableDictionary alloc] init];
        
        ASINetworkQueue *tmpInfoQueue = [[ASINetworkQueue alloc] init];
        [tmpInfoQueue setDelegate:self];
        [tmpInfoQueue setShouldCancelAllRequestsOnFailure:NO];
        [tmpInfoQueue setRequestDidFailSelector:@selector(didRequestFailed:)];
        [tmpInfoQueue setRequestDidFinishSelector:@selector(didRequestFinished:)];
        [tmpInfoQueue setQueueDidFinishSelector:@selector(infoQueueFinished:)];
        self.infoQueue = tmpInfoQueue;
        [tmpInfoQueue release];
        
        ASINetworkQueue *tmpImageQueue = [[ASINetworkQueue alloc] init];
        [tmpImageQueue setDelegate:self];
        [tmpImageQueue setShouldCancelAllRequestsOnFailure:NO];
        [tmpImageQueue setRequestDidFailSelector:@selector(didRequestFailed:)];
        [tmpImageQueue setRequestDidFinishSelector:@selector(didRequestFinished:)];
        [tmpImageQueue setQueueDidFinishSelector:@selector(imageQueueFinished:)];
        self.imageQueue = tmpImageQueue;
        [tmpImageQueue release];

    }
    
    return self;
}

- (void)dealloc
{
    [_activeDownload release];
    [_artistIndexPathDict removeAllObjects];
    [_artistIndexPathDict release];
    [super dealloc];
}

#pragma mark -
#pragma mark ASIHTTP Delegate Methods
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
- (void)infoQueueFinished:(ASINetworkQueue *)queue
{
    NSArray *artists = [self.infoQueue.userInfo objectForKey:@"artists"];
    [_delegate didDownloadArtistQueue:artists];
	NSLog(@"Info Queue finished");
}

- (void)imageQueueFinished:(ASINetworkQueue *)queue
{
    
	NSLog(@"Image Queue finished");
}

#pragma mark -
#pragma mark Album Methods
- (void)downloadAlbumInfo:(Album *)album
{
    
}

#pragma mark -
#pragma mark Artists Methods
- (void)downloadArtistInfo:(NSArray *)artists;
{
    static NSString *LastFMAPIKey = @"1ec0d3d1928d823fb7a58440c1d6ca65";
    for (Artist *artist in artists){
        NSString *searchString = [artist.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"SearchString %@", searchString);
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=artist.getInfo&artist=%@&api_key=%@&format=json&autocorrect=1", searchString, LastFMAPIKey]];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"artist", @"type", @"info", @"phase", artist, @"artist", nil];
        request.userInfo = dict;
        [dict release];
        
        [self.infoQueue addOperation:request];
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:artists, @"artists", nil];
    self.infoQueue.userInfo = dict;
    [self.infoQueue go];
    
}

//Receives the data and formats into jso and downloads the artist image
- (void)processArtistInfo:(ASIHTTPRequest *)request
{
    Artist *artist = [request.userInfo objectForKey:@"artist"];
    NSLog(@"Artist Name %@", artist.name);
    
    NSString *responseString = [request responseString];
    NSDictionary *artistDict = [[responseString JSONValue] objectForKey:@"artist"];
    
    artist.mbid = [artistDict objectForKey:@"mbid"];
    artist.name = [artistDict objectForKey:@"name"];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *image in [artistDict objectForKey:@"image"]){
        [dict setObject:[image objectForKey:@"#text"] forKey:[image objectForKey:@"size"]];
    }
    artist.thumbs = dict;
    [dict release];
    
}

- (void)downloadArtistThumb:(Artist *)artist withIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [[NSURL alloc] initWithString:[artist.thumbs objectForKey:@"medium"]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"artist", @"type", @"image", @"phase", artist, @"artist", indexPath, @"indexPath", nil];
    request.userInfo = dict;
    [dict release];
    
    [self.imageQueue addOperation:request];
    [self.imageQueue go];

}

- (void)processArtistThumbImage:(ASIHTTPRequest *)request
{
    NSLog(@"Got here");
    
    NSIndexPath *indexPath = [request.userInfo objectForKey:@"indexPath"];
    Artist *artist = [request.userInfo objectForKey:@"artist"];
    artist.smallImageThumb = [UIImage imageWithData:[request rawResponseData]];
    [_delegate didDownloadArtistThumb:artist forIndexPath:indexPath];
}

#pragma mark -
#pragma mark Helper methods
- (NSString *)encodeIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    NSString *indexPathStr = [NSString stringWithFormat:@"%d_%d", section, row];
    return indexPathStr;
}

@end
