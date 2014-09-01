#import "PPPreferenceProtect.h"

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	// Setup
	[[%c(PPPreferenceProtect) sharedInstance] setShouldLog:YES forPaneWithName:@"Wi-Fi"];
	// This is rather unneccesary here as the values just get reset again
	if([[%c(PPPreferenceProtect) sharedInstance] paneExists:@"Wi-Fi"]) {
		[[%c(PPPreferenceProtect) sharedInstance] removePasswordForPaneWithName:@"Wi-Fi" withPassword:@"123"];
	}
	[[%c(PPPreferenceProtect) sharedInstance] addPassword:@"123" forPaneWithName:@"Wi-Fi"];

	// Customize stuff
	[[%c(PPPreferenceProtect) sharedInstance] setKeyboardType:UIKeyboardTypeNumberPad forPaneWithName:@"Wi-Fi"];
	[[%c(PPPreferenceProtect) sharedInstance] setAlertTitle:@"Example" forPaneWithName:@"Wi-Fi"];
	[[%c(PPPreferenceProtect) sharedInstance] setEnterButtonTitle:@"Ok" forPaneWithName:@"Wi-Fi"];
}

%end
