#import "PPPreferenceProtect.h"

@interface SBIcon : NSObject
- (id)applicationBundleID;
@end

@interface SBIconView : UIView
@property (retain, nonatomic) SBIcon *icon;
@end

%hook SBIconController

- (void)iconTapped:(id)arg1 {
	%orig;
	NSString* appID = [(SBIcon *)[(SBIconView *)arg1 icon] applicationBundleID];
	if([appID isEqualToString:@"com.apple.Preferences"]) {
		
		//Setup
		[[%c(PPPreferenceProtect) sharedInstance] removePasswordForPaneWithName:@"Wi-Fi" withPassword:@"123"];
		[[%c(PPPreferenceProtect) sharedInstance] addPassword:@"123" forPaneWithName:@"Wi-Fi"];

		//Customize stuff
		[[%c(PPPreferenceProtect) sharedInstance] setKeyboardType:UIKeyboardTypeNumberPad forPaneWithName:@"Wi-Fi"];
		[[%c(PPPreferenceProtect) sharedInstance] setAlertTitle:@"Example" forPaneWithName:@"Wi-Fi"];
		[[%c(PPPreferenceProtect) sharedInstance] setEnterButtonTitle:@"Go" forPaneWithName:@"Wi-Fi"];

	}
}

%end
