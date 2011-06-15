//
//  RootViewController.m
//  MediaPlayer
//
//  Created by Daniel Barden on 5/31/11.
//  Copyright 2011 None. All rights reserved.
//

#import "RootViewController.h"
#import "AlbumsViewController.h"
#import "Artist.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation RootViewController

@synthesize artists=_artists;
@synthesize downloadManager=_downloadManager;

- (void)viewDidLoad
{
    self.title = @"My Music";

    //Initializes DownloadManager
    DownloadManager *manager = [[DownloadManager alloc] init];
    manager.delegate = self;
    self.downloadManager = manager;
    [manager release];
    
    //Gets the Artists presents and creates an array
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query setGroupingType:MPMediaGroupingArtist];
    NSArray *collections = [query collections];

    NSMutableArray *tmp = [[NSMutableArray alloc] init];

    for (MPMediaItemCollection *media in collections){
        MPMediaItem *item = [media representativeItem];
        if ([[item valueForProperty:MPMediaItemPropertyMediaType] isEqualToNumber:[NSNumber numberWithInt:MPMediaTypeMusic]]){
            Artist *artist = [[Artist alloc] init];
            artist.name = [item valueForProperty:MPMediaItemPropertyArtist];
            [tmp addObject:artist];
            [artist release];
        }
    }
    self.artists = [self prepareData:tmp];
    
    [tmp release];
    [super viewDidLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)prepareData:(NSArray*)data{
    NSMutableDictionary *tableData = [NSMutableDictionary dictionary];
    
    UILocalizedIndexedCollation *indexer = [UILocalizedIndexedCollation currentCollation];
    for (Artist *at in data){
        NSInteger index = [indexer sectionForObject:at collationStringSelector:@selector(sortableName)];
        NSNumber *key = [[NSNumber alloc] initWithInteger:index];
        NSMutableArray *array = [tableData objectForKey:key];
        
        if (array == nil){
            array = [NSMutableArray new];
            [tableData setObject:array forKey:key];
        }
        [array addObject:at];
        [key release];
    }
    
    NSArray *keys = [tableData allKeys];
    for (NSNumber *key in keys){
        NSArray *array = [tableData objectForKey:key];
        NSArray *sortedArray = [indexer sortedArrayFromArray:array collationStringSelector:@selector(sortableName)];
        [tableData setObject:sortedArray forKey:key];
    }
    return tableData;
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_artists allKeys] count];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [[_artists allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int title = [[keys objectAtIndex:section] intValue]+65;
    
    return [[[NSString alloc] initWithFormat:@"%c", title] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [[_artists allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *key = [keys objectAtIndex:section];
    
    NSUInteger count = [[_artists objectForKey:key] count];
    return count;
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionTitles];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //Image place
        CGRect imgRect = CGRectMake(2, 2, 40, 40);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgRect];
        imgView.tag = kCoverKey;
        [cell.contentView addSubview:imgView];
        [imgView release];
        
        //Movie Name
        CGRect nameLabelRect = CGRectMake(70, 10, 200, 30);
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:nameLabelRect];
        nameLabel.tag = kNameKey;
        nameLabel.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:nameLabel];
        [nameLabel release];
    }

    // Configure the cell.
    NSInteger row = [indexPath row];

    NSArray *keys = [[_artists allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *key = [keys objectAtIndex:indexPath.section];
    NSArray *array = [_artists objectForKey:key];
    Artist *at = [array objectAtIndex:row];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:kCoverKey];
    cellImageView.contentMode = UIViewContentModeScaleToFill;
    if (at.smallImageThumb == nil){
        cellImageView.image = [UIImage imageNamed:@"Placeholder.png"];
        
        [_downloadManager downloadArtistInfo:at withIndexPath:indexPath];
    } else {
        cellImageView.image = at.smallImageThumb;
    }

    UILabel *name = (UILabel *)[cell viewWithTag:kNameKey];
    name.text = at.name;

    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFinishArtistDownload:(Artist *)artist forIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Cell %@", cell.textLabel.text);
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:kCoverKey];
    imgView.image = artist.smallImageThumb;
}
@end
