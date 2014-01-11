//
//  DRTestSettingsPlugin.m
//  Doktor TV
//
//  Created by Tobias DM on 11/01/14.
//  Copyright (c) 2014 developmunk. All rights reserved.
//

#import "DRTestSettingsPlugin.h"

#import "DataHandler.h"
#import "DRHandler.h"

@interface DRTestSettingsPlugin () <UITableViewDataSource, UITableViewDelegate>
@end


@implementation DRTestSettingsPlugin



#define cellIdentifier @"DRCellIdentifier"



- (void)setup
{
	self.name = @"DR";
	self.uniqueID = @"DR";
//	self.parameterDefaults = @{};
	
	UITableViewController *tableViewController = [UITableViewController new];
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = tableView;
	self.viewController = tableViewController;
	
	[tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
	tableViewController.tableView.dataSource = self;
	tableViewController.tableView.delegate = self;
}



- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	
	[self updateToNewSettings];
}

- (void)updateToNewSettings
{
}


- (NSString *)settingsDescription
{
	return @"";
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Clear data";
		case 1: return @"Fetch data";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return 4;
		case 1: return 3;
		default: return 0;
	}
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	cell.accessoryView = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
	switch (indexPath.section) {
		case 0:
		{
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"All";
					break;
				case 1:
					cell.textLabel.text = @"Core Data";
					break;
				case 2:
					cell.textLabel.text = @"Caches (images)";
					break;
				case 3:
					cell.textLabel.text = @"Persistent (videos)";
					break;
					
				default:
					break;
			}
		}
			break;
		case 1:
		{
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"All – 100%";
					break;
				case 1:
					cell.textLabel.text = @"90%";
					break;
				case 2:
					cell.textLabel.text = @"10%";
					break;
					
				default:
					break;
			}
		}
			break;
		default:
			break;
	}
	
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
				{
					[[DataHandler sharedInstance] clearCaches];
					[[DataHandler sharedInstance] clearPersistent];
					[[DataHandler sharedInstance] clearCoreData];
					[[DataHandler sharedInstance] saveContext];
				}
					break;
				case 1:
				{
					[[DataHandler sharedInstance] clearCoreData];
					[[DataHandler sharedInstance] saveContext];
				}
					break;
				case 2:
				{
					[[DataHandler sharedInstance] clearCaches];
				}
					break;
				case 3:
				{
					[[DataHandler sharedInstance] clearPersistent];
				}
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
				{
					[[DRHandler sharedInstance] queryPrograms];
				}
					break;
				case 1:
				{
					[[DRHandler sharedInstance] queryPrograms9outof10];
				}
					break;
				case 2:
				{
					[[DRHandler sharedInstance] queryPrograms1outof10];
				}
					break;
			}
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
