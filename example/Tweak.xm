#import "PPPreferenceProtect.h"

#define PPPaneName @"Wi-Fi"

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	// Setup
	[[%c(PPPreferenceProtect) sharedInstance] setShouldLog:YES forPaneWithName:PPPaneName];
	// This is rather unneccesary here as the values just get reset again
	if([[%c(PPPreferenceProtect) sharedInstance] paneExists:PPPaneName]) {
		[[%c(PPPreferenceProtect) sharedInstance] removePasswordForPaneWithName:PPPaneName withPassword:@"123"];
	}
	[[%c(PPPreferenceProtect) sharedInstance] addPassword:@"123" forPaneWithName:PPPaneName];

	// Customize stuff
	[[%c(PPPreferenceProtect) sharedInstance] setAutoAccept:YES forPaneWithName:PPPaneName];
	[[%c(PPPreferenceProtect) sharedInstance] setKeyboardType:UIKeyboardTypeNumberPad forPaneWithName:PPPaneName];
	[[%c(PPPreferenceProtect) sharedInstance] setAlertTitle:@"Example: Wi-Fi" forPaneWithName:PPPaneName];
	[[%c(PPPreferenceProtect) sharedInstance] setEnterButtonTitle:@"Ok" forPaneWithName:PPPaneName];
	[[%c(PPPreferenceProtect) sharedInstance] setAlertPlaceholder:@"Password..." forPaneWithName:PPPaneName];
}

%end
