#import "NSString+Hashes.h"
#import "UIAlertView+IABlocks.h"
#import "UIDeviceHardware.h"
#import <notify.h>
#import "PPPreferenceProtect.h"
#import <Preferences/Preferences.h>

#define log(z) NSLog(@"[libPreferenceProtect] %@", z)

@interface PrefsListController : PSListController <UITableViewDelegate, UITableViewDataSource>
- (void)showPromptWithTableView:(UITableView *)tableView andRow:(int)row inSection:(int)section forPaneName:(NSString *)name;
- (void)showForgotPromptWithTableView:(UITableView *)tableView andRow:(int)row inSection:(int)section forPaneName:(NSString *)name;
@end

NSString* password, * forgotPassword;
UIAlertView* alertPrompt;
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

BOOL enterBnHidden;

%new
- (void)showPromptWithTableView:(UITableView *)tableView andRow:(int)row inSection:(int)section forPaneName:(NSString *)name {

	NSDictionary* customizationDict = [PPPreferenceProtect sharedInstance].lockedPanes[name];
	if(!customizationDict) {
		shouldBlock = NO;
		[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
		return;
	}

	// Getters

	password = customizationDict[@"Password"];
	if(!password || [password length] == 0) {
		shouldBlock = NO;
		[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
		return;
	}

	BOOL securePassword = [customizationDict[@"securePassword"] boolValue];
	if(!customizationDict[@"securePassword"]) {
		securePassword = YES;
	}

	BOOL autoAccept = [customizationDict[@"autoAccept"] boolValue];
	if(!customizationDict[@"autoAccept"]) {
		autoAccept = NO;
	}

	NSString* alertTitle = customizationDict[@"alertTitle"];
	if(!alertTitle || [alertTitle length] == 0) {
		alertTitle = name;
	}

	NSString* alertMessage = customizationDict[@"alertMessage"];
	if(!alertMessage || [alertMessage length] == 0) {
		alertMessage = @"Enter Password:";
	}

	NSString* placeholder = customizationDict[@"placeholder"];
	if(!placeholder || [placeholder length] == 0) {
		placeholder = @"Password";
	}

	NSString* cancelBnTitle = customizationDict[@"cancelBnTitle"];
	if(!cancelBnTitle || [cancelBnTitle length] == 0) {
		cancelBnTitle = @"Cancel";
	}

	enterBnHidden = [customizationDict[@"enterBnHidden"] boolValue];
	if(!customizationDict[@"enterBnHidden"]) {
		enterBnHidden = NO;
	}

	NSString* enterBnTitle = customizationDict[@"enterBnTitle"];
	if(!enterBnTitle || [enterBnTitle length] == 0) {
		enterBnTitle = @"Enter";
	}

	NSString* forgotBnTitle = customizationDict[@"forgotBnTitle"];
	if(!forgotBnTitle || [forgotBnTitle length] == 0) {
		forgotBnTitle = @"Forgot Password";
	}

	UIKeyboardType keyboardType = [customizationDict[@"keyboardType"] intValue];
	if(!keyboardType) {
		keyboardType = UIKeyboardTypeDefault;
	}

	// Forgot button getters

	BOOL forgotEnabled = [customizationDict[@"forgotEnabled"] boolValue];
	if(!customizationDict[@"forgotEnabled"]) {
		forgotEnabled = NO;
	}

	alertPrompt = [[UIAlertView alloc]
		initWithTitle: alertTitle
		message: alertMessage
		cancelButtonTitle: cancelBnTitle
		otherButtonTitles: nil];
	if(!enterBnHidden)
		[alertPrompt addButtonWithTitle: enterBnTitle];
	if(forgotEnabled)
		[alertPrompt addButtonWithTitle: forgotBnTitle];

	UIAlertViewStyle alertStyle = UIAlertViewStylePlainTextInput;
	if(securePassword) {
		alertStyle = UIAlertViewStyleSecureTextInput;
	}
	[alertPrompt setAlertViewStyle:alertStyle];
	
	if(autoAccept) {
		[[alertPrompt textFieldAtIndex:0] addTarget:self action:@selector(passwordTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}

	[alertPrompt textFieldAtIndex:0].placeholder = placeholder;
	[alertPrompt textFieldAtIndex:0].keyboardType = keyboardType;

	[alertPrompt setHandler: ^(UIAlertView* alert, NSInteger buttonIndex) {
	    log(@"Pressed Enter");
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
	} forButtonAtIndex: (enterBnHidden ? 673 : 1)];

	[alertPrompt setHandler: ^(UIAlertView* alert, NSInteger buttonIndex) {
	    log(@"Pressed Forgot Password");
	    [self showForgotPromptWithTableView:tableView andRow:row inSection:section forPaneName:name];
	} forButtonAtIndex: (forgotEnabled && enterBnHidden ? 1 : (forgotEnabled && !enterBnHidden ? 2 : 674))];

	[alertPrompt setHandler: ^(UIAlertView* alert, NSInteger buttonIndex) {
		log(@"Pressed Cancel");
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

%new
- (void)passwordTextFieldDidChange:(UITextField *)textField {
    if([[textField.text sha1] isEqualToString: password]) {
    	[alertPrompt dismissWithClickedButtonIndex:-1 animated:YES];
        [alertPrompt.delegate alertView:alertPrompt clickedButtonAtIndex:(enterBnHidden ? 673 : 1)];
    }
}

%new
- (void)showForgotPromptWithTableView:(UITableView *)tableView andRow:(int)row inSection:(int)section forPaneName:(NSString *)name {

	NSDictionary* customizationDict = [PPPreferenceProtect sharedInstance].lockedPanes[name];
	if(!customizationDict) {
		shouldBlock = NO;
		[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
		return;
	}

	// Forgot button getters

	forgotPassword = customizationDict[@"forgotPassword"];
	if(!forgotPassword || [forgotPassword length] == 0) {
		shouldBlock = NO;
		[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
		return;
	}

	BOOL forgotEnabled = [customizationDict[@"forgotEnabled"] boolValue];
	if(!customizationDict[@"forgotEnabled"]) {
		forgotEnabled = NO;
	}

	BOOL forgotSecurePassword = [customizationDict[@"forgotSecurePassword"] boolValue];
	if(!customizationDict[@"forgotSecurePassword"]) {
		forgotSecurePassword = YES;
	}

	BOOL forgotAutoAccept = [customizationDict[@"forgotAutoAccept"] boolValue];
	if(!customizationDict[@"forgotAutoAccept"]) {
		forgotAutoAccept = NO;
	}

	NSString* forgotAlertTitle = customizationDict[@"forgotAlertTitle"];
	if(!forgotAlertTitle || [forgotAlertTitle length] == 0) {
		forgotAlertTitle = @"Forgot Password";
	}

	NSString* forgotAlertMessage = customizationDict[@"forgotAlertMessage"];
	if(!forgotAlertMessage || [forgotAlertMessage length] == 0) {
		forgotAlertMessage = @"Enter Password:";
	}

	NSString* forgotPlaceholder = customizationDict[@"forgotPlaceholder"];
	if(!forgotPlaceholder || [forgotPlaceholder length] == 0) {
		forgotPlaceholder = @"Password";
	}

	NSString* forgotCancelBnTitle = customizationDict[@"forgotCancelBnTitle"];
	if(!forgotCancelBnTitle || [forgotCancelBnTitle length] == 0) {
		forgotCancelBnTitle = @"Cancel";
	}

	BOOL forgotEnterBnHidden = [customizationDict[@"forgotEnterBnHidden"] boolValue];
	if(!customizationDict[@"forgotEnterBnHidden"]) {
		forgotEnterBnHidden = NO;
	}

	NSString* forgotEnterBnTitle = customizationDict[@"forgotEnterBnTitle"];
	if(!forgotEnterBnTitle || [forgotEnterBnTitle length] == 0) {
		forgotEnterBnTitle = @"Enter";
	}

	UIKeyboardType forgotKeyboardType = [customizationDict[@"forgotKeyboardType"] intValue];
	if(!forgotKeyboardType) {
		forgotKeyboardType = UIKeyboardTypeDefault;
	}

	BOOL forgotCorrectEnterPane = [customizationDict[@"forgotCorrectEnterPane"] boolValue];
	if(!customizationDict[@"forgotCorrectEnterPane"]) {
		forgotCorrectEnterPane = YES;
	}

	NSString* forgotCorrectNotify = customizationDict[@"forgotCorrectNotify"];

	alertPrompt = [[UIAlertView alloc]
		initWithTitle: forgotAlertTitle
		message: forgotAlertMessage
		cancelButtonTitle: forgotCancelBnTitle
		otherButtonTitles: nil];
	if(!forgotEnterBnHidden)
		[alertPrompt addButtonWithTitle: forgotEnterBnTitle];

	UIAlertViewStyle forgotAlertStyle = UIAlertViewStylePlainTextInput;
	if(forgotSecurePassword) {
		forgotAlertStyle = UIAlertViewStyleSecureTextInput;
	}
	[alertPrompt setAlertViewStyle:forgotAlertStyle];
	
	if(forgotAutoAccept) {
		[[alertPrompt textFieldAtIndex:0] addTarget:self action:@selector(forgotPasswordTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}

	[alertPrompt textFieldAtIndex:0].placeholder = forgotPlaceholder;
	[alertPrompt textFieldAtIndex:0].keyboardType = forgotKeyboardType;

	[alertPrompt setHandler: ^(UIAlertView* alert, NSInteger buttonIndex) {
		log(@"Forgot Pressed Enter");
	    if([[[[alert textFieldAtIndex: 0] text] sha1] isEqualToString: forgotPassword]) {
	    	if([forgotCorrectNotify length] > 0)
	    		notify_post([forgotCorrectNotify UTF8String]);
	        if(forgotCorrectEnterPane) {
	        	shouldBlock = NO;
	        	[self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
	        }
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
		log(@"Forgot Pressed Cancel");
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

%new
- (void)forgotPasswordTextFieldDidChange:(UITextField *)textField {
    if([[textField.text sha1] isEqualToString: forgotPassword]) {
        [alertPrompt dismissWithClickedButtonIndex:-1 animated:YES];
        [alertPrompt.delegate alertView:alertPrompt clickedButtonAtIndex:1];
    }
}

%end
