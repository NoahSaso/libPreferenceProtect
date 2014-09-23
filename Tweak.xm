#import "AES.m"

#import "PPPreferenceProtect.h"
#define PPSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.sassoty.libpreferenceprotect.plist"]
#define PPEnDecryptKey [[[UIDevice currentDevice] identifierForVendor] UUIDString]

void refreshPanes() {

	NSLog(@"[libPreferenceProtect] Refreshing panes...");

	NSDictionary* prefs = [[NSDictionary alloc] initWithContentsOfFile:PPSettingsPath];
	
	NSMutableArray* titles = [[NSMutableArray alloc] init];
	NSMutableArray* passwords = [[NSMutableArray alloc] init];

	for(NSString* i in [prefs allKeys]) {
		if([i hasPrefix:@"title-"]) {
			[titles addObject:prefs[i]];
		}else if([i hasPrefix:@"pass-"]) {
			[passwords addObject:prefs[i]];
		}
	}

	for(NSString* i in titles) {
		
		int index = [titles indexOfObject:i];

		if([passwords count] - 1 < index) { continue; }

		NSData* decryptedPass = [passwords[index] AES256DecryptWithKey:PPEnDecryptKey];
		NSString* password = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:decryptedPass encoding:NSUTF8StringEncoding] UTF8String]];

		BOOL autoAccept = [prefs[[NSString stringWithFormat:@"autoAccept-%d", index + 1]] boolValue];
		if(!prefs[[NSString stringWithFormat:@"autoAccept-%d", index + 1]]) {
			autoAccept = YES;
		}

		BOOL numberKeypad = [prefs[[NSString stringWithFormat:@"numberKeypad-%d", index + 1]] boolValue];
		if(!prefs[[NSString stringWithFormat:@"numberKeypad-%d", index + 1]]) {
			numberKeypad = NO;
		}

		[[%c(PPPreferenceProtect) sharedInstance] setShouldLog:YES forPaneWithName:i];
		[[%c(PPPreferenceProtect) sharedInstance] addPassword:password forPaneWithName:i];
		[[%c(PPPreferenceProtect) sharedInstance] setAutoAccept:autoAccept forPaneWithName:i];
		[[%c(PPPreferenceProtect) sharedInstance] setKeyboardType:numberKeypad forPaneWithName:i];

	}

}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	refreshPanes();
}

%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
        NULL,
        (CFNotificationCallback)refreshPanes,
        CFSTR("com.sassoty.libpreferenceprotect/preferencechanged"),
        NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
}
