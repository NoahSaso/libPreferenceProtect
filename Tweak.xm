#import "NSString+Hashes.h"
#import "UIAlertView+IABlocks.h"
#import "UIDeviceHardware.h"

#import "PPPreferenceProtect.h"

#import <Preferences/Preferences.h>
@interface PrefsListController : PSListController <UITableViewDelegate, UITableViewDataSource>
- (void)showPromptWithTableView:(UITableView *)tableView andRow:(int)row inSection:(int)section forPaneName:(NSString *)name;
@end

NSIndexPath* previousSelectedPath;
BOOL shouldBlock = YES;

%hook PrefsListController

- (void)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	previousSelectedPath = [tableView indexPathForSelectedRow];
	%orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if(!shouldBlock) {
		shouldBlock = YES;
		%orig;
		return;
	}

	if([PPPreferenceProtect sharedInstance].lockedPanes.count == 0) {
		%orig;
		return;
	}

	PSTableCell* cell = (PSTableCell *)[tableView cellForRowAtIndexPath:indexPath];
	NSString* paneName = [cell title];

	for(NSString* name in [[PPPreferenceProtect sharedInstance].lockedPanes allKeys]) {
		if([name isEqualToString:paneName]) {
			[self showPromptWithTableView: tableView andRow: indexPath.row inSection: indexPath.section forPaneName:name];
			return;
		}
	}

	%orig;

}

%new
- (void)showPromptWithTableView:(UITableView *)tableView andRow:(int)row inSection:(int)section forPaneName:(NSString *)name {

	NSDictionary* customizationDict = [PPPreferenceProtect sharedInstance].lockedPanes[name];
	if(!customizationDict) {
		return;
	}

	NSString* password = customizationDict[@"Password"];
	if(!password || [password length] == 0) {
		return;
	}

	BOOL securePassword = [customizationDict[@"securePassword"] boolValue];
	if(!customizationDict[@"securePassword"]) {
		securePassword = YES;
	}

	NSString* alertTitle = customizationDict[@"alertTitle"];
	if(!alertTitle || [alertTitle length] == 0) {
		alertTitle = name;
	}

	NSString* alertMessage = customizationDict[@"alertMessage"];
	if(!alertMessage) {
		alertMessage = @"Enter Password:";
	}

	NSString* cancelBnTitle = customizationDict[@"cancelBnTitle"];
	if(!cancelBnTitle) {
		cancelBnTitle = @"Cancel";
	}

	NSString* enterBnTitle = customizationDict[@"enterBnTitle"];
	if(!enterBnTitle) {
		enterBnTitle = @"Enter";
	}

	UIKeyboardType keyboardType = [customizationDict[@"keyboardType"] intValue];
	if(!keyboardType) {
		keyboardType = UIKeyboardTypeDefault;
	}

	UIAlertView* alertPrompt = [[UIAlertView alloc]
		initWithTitle: alertTitle
		message: alertMessage
		cancelButtonTitle: cancelBnTitle
		otherButtonTitles: enterBnTitle, nil];

	UIAlertViewStyle alertStyle = UIAlertViewStylePlainTextInput;
	if(securePassword) {
		alertStyle = UIAlertViewStyleSecureTextInput;
	}
	[alertPrompt setAlertViewStyle:alertStyle];

	[alertPrompt textFieldAtIndex:0].keyboardType = keyboardType;

	[alertPrompt setHandler: ^(UIAlertView* alert, NSInteger buttonIndex) {
	    if([[[[alert textFieldAtIndex: 0] text] sha1] isEqualToString: password]) {
	        shouldBlock = NO;
	        [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
	    }else {
	        UIDeviceHardware* h = [[%c(UIDeviceHardware) alloc] init];
	        if([[h platform] rangeOfString:@"iPad"].location != NSNotFound) {
	        	[tableView selectRowAtIndexPath:previousSelectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	        	[tableView scrollToRowAtIndexPath:previousSelectedPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	        }else {
	        	[tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES];
	        }
	    }
	} forButtonAtIndex: 1];

	[alertPrompt setHandler: ^(UIAlertView* alert, NSInteger buttonIndex) {
	    UIDeviceHardware* h = [[%c(UIDeviceHardware) alloc] init];
	    if([[h platform] rangeOfString:@"iPad"].location != NSNotFound) {
	    	[tableView selectRowAtIndexPath:previousSelectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	    	[tableView scrollToRowAtIndexPath:previousSelectedPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	    }else {
	    	[tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES];
	    }
	} forButtonAtIndex: 0];

	[alertPrompt show];

}

%end
