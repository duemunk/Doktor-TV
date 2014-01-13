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
{
	UITableView *_tableView;
}



#define cellIdentifier @"DRCellIdentifier"


#define kUseOwnServer @"kUseOwnServer"

- (void)setup
{
	self.name = @"DR";
	self.uniqueID = @"DR";
	self.parameterDefaults = @{ kUseOwnServer : @YES };
	
	UITableViewController *tableViewController = [UITableViewController new];
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableViewController.tableView = _tableView;
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
	[DRHandler sharedInstance].useOwnServer = [[[DMTestSettings sharedInstance] objectForKey:kUseOwnServer withPluginIdentifier:self.uniqueID] boolValue];
}


- (NSString *)settingsDescription
{
	return @"";
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return @"Clear data";
		case 1: return @"Fetch data";
		case 2: return @"Server";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0: return 4;
		case 1: return 3;
		case 2: return 1;
		default: return 0;
	}
}


#pragma mark - UITableViewDelegate

#define switchViewTag 120934875

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	[self configureCell:cell forIndexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
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
		case 2:
		{
			switch (indexPath.row) {
				case 0:
				{
					cell.textLabel.text = @"Use own server";
					
					int useOwnServer = [[[DMTestSettings sharedInstance] objectForKey:kUseOwnServer withPluginIdentifier:self.uniqueID] boolValue];
					cell.detailTextLabel.text = nil;
					
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
					
					UISwitch *_switch;
					if (cell.accessoryView.tag == switchViewTag)
					{
						_switch = (UISwitch *)cell.accessoryView;
						[_switch removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
					}
					else
					{
						_switch = [UISwitch new];
						_switch.tag = switchViewTag;
						cell.accessoryView = _switch;
					}
					_switch.on = useOwnServer;
					[_switch addTarget:self action:@selector(useOwnServerSwitchChanged:) forControlEvents:UIControlEventValueChanged];
				}
					break;
			}
		}
			break;
		default:
			break;
	}
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



- (void)useOwnServerSwitchChanged:(UISwitch *)_switch
{
	UITableViewCell *cell;
	if ([_switch.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)_switch.superview;
	}
	else if ([_switch.superview.superview isKindOfClass:[UITableViewCell class]]) {
		cell = (UITableViewCell *)_switch.superview.superview;
	}
	if (cell)
	{
		int useOwnServer = _switch.on;
		[[DMTestSettings sharedInstance] setObject:@(useOwnServer) forKey:kUseOwnServer withPluginIdentifier:self.uniqueID];
		[DRHandler sharedInstance].useOwnServer = useOwnServer;
		NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
		[self configureCell:cell forIndexPath:indexPath];
	}
}



@end
