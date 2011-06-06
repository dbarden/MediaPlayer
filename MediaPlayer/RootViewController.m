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

@synthesize artists;

- (void)viewDidLoad
{
    self.title = @"My Music";

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.artists allKeys] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [[self.artists allKeys] sortedArrayUsingSelector:@selector(compare:)];
    int title = [[keys objectAtIndex:section] intValue]+65;
    
    return [[[NSString alloc] initWithFormat:@"%c", title] autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [[self.artists allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *key = [keys objectAtIndex:section];
    
    NSUInteger count = [[self.artists objectForKey:key] count];
    return count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    NSInteger row = [indexPath row];

    NSArray *keys = [[self.artists allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSNumber *key = [keys objectAtIndex:indexPath.section];
    NSArray *array = [self.artists objectForKey:key];
    
    Artist *at = [array objectAtIndex:row];
    cell.textLabel.text = [at name];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 /*   
    AlbumsViewController *albumsViewController = [[AlbumsViewController alloc] init];
    albumsViewController.artist = [self.artists objectAtIndex:[indexPath row]];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:albumsViewController animated:YES];
    [albumsViewController release];
  */
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor redColor];
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

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
@end
