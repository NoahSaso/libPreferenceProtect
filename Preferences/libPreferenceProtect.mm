#import <Preferences/Preferences.h>
#import <substrate.h>
#import "AES.m"

#import <notify.h>

#import "../PPPreferenceProtect.h"
#define PPSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.sassoty.libpreferenceprotect.plist"]
#define PPEnDecryptKey [[[UIDevice currentDevice] identifierForVendor] UUIDString]

#define plog(...) NSLog(@"[libPreferenceProtect] %@", ##__VA_ARGS__);

@interface PSListController (FixingSuper)
- (void)viewDidLoad;
@end

@interface PSSpecifier (PSButtonCell)
- (void)setButtonAction:(SEL)action;
@end

@interface libPreferenceProtectListController: PSListController {
	int count;
}
@end

@implementation libPreferenceProtectListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"libPreferenceProtect" target:self] retain];
	}
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self createNew];
}

- (void)createNew {
	count = 1;

	NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:PPSettingsPath];
	if(!dict) { return;	}

	//Y U NO WORK!?
	//int top = ceil([dict count] / 4);
	int top = 0;
	if(([dict count] % 4) > 0) {
		top = floor([dict count] / 4) + 1;
	}else {
		top = [dict count] / 4;
	}

	for(int i = 0; i < top; i++) {
		[self new];
	}
}

- (void)new {

	NSMutableArray* newEntry = [[NSMutableArray alloc] init];

	PSSpecifier* groupNameSpecifier = [PSSpecifier groupSpecifierWithName:[NSString stringWithFormat:@"Pane %d", count]];

	PSTextFieldSpecifier* titleSpecifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Pane Title" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:nil];
	[titleSpecifier setPlaceholder:@"Pane Title..."];
	[titleSpecifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	[titleSpecifier setProperty:@"com.sassoty.libpreferenceprotect" forKey:@"defaults"];
	[titleSpecifier setProperty:[self getLatestID:YES] forKey:@"key"];
	[titleSpecifier setProperty:@"com.sassoty.libpreferenceprotect/preferencechanged" forKey:@"PostNotification"];

	PSTextFieldSpecifier* passwordSpecifier = [PSTextFieldSpecifier preferenceSpecifierNamed:@"Password" target:self set:@selector(setPreferenceValueEncrypted:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSecureEditTextCell edit:nil];
	[passwordSpecifier setPlaceholder:@"Password..."];
	[passwordSpecifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	[passwordSpecifier setProperty:@"com.sassoty.libpreferenceprotect" forKey:@"defaults"];
	[passwordSpecifier setProperty:[self getLatestID:NO] forKey:@"key"];
	[passwordSpecifier setProperty:@"com.sassoty.libpreferenceprotect/preferencechanged" forKey:@"PostNotification"];

	PSSpecifier* autoAcceptSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Auto Accept" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
	[autoAcceptSpecifier setProperty:@"com.sassoty.libpreferenceprotect/preferencechanged" forKey:@"PostNotification"];
	[autoAcceptSpecifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	[autoAcceptSpecifier setProperty:@"com.sassoty.libpreferenceprotect" forKey:@"defaults"];
	[autoAcceptSpecifier setProperty:[NSNumber numberWithBool:YES] forKey:@"default"];
	[autoAcceptSpecifier setProperty:[NSString stringWithFormat:@"autoAccept-%d", count] forKey:@"key"];

	PSSpecifier* numberKeypadSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Number Keypad" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
	[numberKeypadSpecifier setProperty:@"com.sassoty.libpreferenceprotect/preferencechanged" forKey:@"PostNotification"];
	[numberKeypadSpecifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	[numberKeypadSpecifier setProperty:@"com.sassoty.libpreferenceprotect" forKey:@"defaults"];
	[numberKeypadSpecifier setProperty:[NSNumber numberWithBool:NO] forKey:@"default"];
	[numberKeypadSpecifier setProperty:[NSString stringWithFormat:@"numberKeypad-%d", count] forKey:@"key"];

	PSSpecifier* removeSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Remove" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	[removeSpecifier setProperty:@"com.sassoty.libpreferenceprotect/preferencechanged" forKey:@"PostNotification"];
	[removeSpecifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
	[removeSpecifier setProperty:@"com.sassoty.libpreferenceprotect" forKey:@"defaults"];
	//MSHookIvar<SEL>(removeSpecifier, "action") = @selector(remove:);
	[removeSpecifier setButtonAction:@selector(remove:)];

	[newEntry addObject:groupNameSpecifier];
	[newEntry addObject:titleSpecifier];
	[newEntry addObject:passwordSpecifier];
	[newEntry addObject:autoAcceptSpecifier];
	[newEntry addObject:numberKeypadSpecifier];
	[newEntry addObject:removeSpecifier];

	[self insertContiguousSpecifiers:newEntry atIndex:[[self specifiers] count] animated:YES];

	count++;

}

- (void)setPreferenceValue:(id)arg1 specifier:(id)arg2 {
	if([[(PSSpecifier *)arg2 name] isEqualToString:@"Pane Title"]) {
	
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PPSettingsPath];
		if(!dict) { [super setPreferenceValue:arg1 specifier:arg2]; notify_post("com.sassoty.libpreferenceprotect/preferencechanged"); }

		BOOL shouldSave = YES;
		for(id i in [dict allValues]) {
			if(![i isKindOfClass:[NSString class]]) { continue; }
			if([i isEqualToString:arg1]) {
				shouldSave = NO;
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"libPreferenceProtect" message:@"Pane already exists. You cannot add two passwords on one pane." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];[alert release];
				return;
			}
		}

		if(shouldSave) {
			[super setPreferenceValue:arg1 specifier:arg2];
			notify_post("com.sassoty.libpreferenceprotect/preferencechanged");
		}

	}
}

- (void)remove:(id)specifier {

	NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PPSettingsPath];
	if(!dict) {
		dict = [[NSMutableDictionary alloc] init];
		[dict writeToFile:PPSettingsPath atomically:YES];
	}

	PSSpecifier* spec = (PSSpecifier *)specifier;

	// Subtract two to remove the first two specifiers from the list. I know I don't HAVE to but I am. Deal with it.
	int total = [[self specifiers] count] - 2;
	int index = [[self specifiers] indexOfObject:spec] - 2;
	// I don't expect the outcome to be a decimal, but just in case. (It actually won't ever be a decimal).
	int outcome = (int) round(total / index);

	int newOutcome = (total / 6) - outcome;
	if(newOutcome < 1) newOutcome = 1;
	if(total == index) newOutcome = (total / 6);

	NSString* outcomeStr = [NSString stringWithFormat:@"%d", newOutcome];

	NSData* pass;
	NSString* title;

	for(NSString* i in [dict allKeys]) {
		NSString* numbInKey = [[i componentsSeparatedByString:@"-"] objectAtIndex:1];
		plog([NSString stringWithFormat:@"i: %@ outcomeStr: %@ numbInKey: %@", i, outcomeStr, numbInKey]);
		if([i hasPrefix:@"pass-"]) {
			pass = dict[i];
		}else if([i hasPrefix:@"title-"]) {
			title = dict[i];
		}
		if([numbInKey isEqualToString:outcomeStr]) {
			[dict removeObjectForKey:i];
		}
	}

	NSData* decryptedPass = [pass AES256DecryptWithKey:PPEnDecryptKey];
	NSString* password = [NSString stringWithUTF8String:[[[NSString alloc] initWithData:decryptedPass encoding:NSUTF8StringEncoding] UTF8String]];

	if([dict writeToFile:PPSettingsPath atomically:YES]) {
		
		plog(@"Wrote remove to file");

		int index = [[self specifiers] indexOfObject:spec];
		for(int i = index; i > (index - 6); i--) {
			[self removeSpecifierAtIndex:i animated:YES];
		}

		// Remove PPPreferenceProtect stuff here
		[[objc_getClass("PPPreferenceProtect") sharedInstance] removePasswordForPaneWithName:title withPassword:password];

		for(int i = 2; i < ([[self specifiers] count] - 2); i++) {
			[self removeSpecifierAtIndex:i animated:YES];
		}

		for(NSString* i in [dict allKeys]) {
			int numbInKey = [[[i componentsSeparatedByString:@"-"] objectAtIndex:1] intValue];
			if(numbInKey > newOutcome) {
				numbInKey--;
			}else { continue; }
			NSString* key = [[[i componentsSeparatedByString:@"-"] objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"%d", numbInKey]];
			NSObject* obj = dict[i];
			[dict removeObjectForKey:i];
			dict[key] = obj;
		}

		[dict writeToFile:PPSettingsPath atomically:YES];

		notify_post("com.sassoty.libpreferenceprotect/preferencechanged");

		[self createNew];

	}else {
		plog(@"Failed writing remove to file");
	}

}

- (void)setPreferenceValueEncrypted:(id)arg1 specifier:(id)specifier {

	NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PPSettingsPath];
	if(!dict) {
		dict = [[NSMutableDictionary alloc] init];
		[dict writeToFile:PPSettingsPath atomically:YES];
	}

	PSSpecifier* spec = (PSSpecifier *)specifier;

	NSString* key = [spec propertyForKey:@"key"];

	dict[key] = [[arg1 dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:PPEnDecryptKey];

	if([dict writeToFile:PPSettingsPath atomically:YES]) {
		plog(@"Encrypted and wrote to file");
		notify_post("com.sassoty.libpreferenceprotect/preferencechanged");
	}else {
		plog(@"Failed encrypting and writing to file");
	}

}

- (NSString *)getLatestID:(BOOL)isTitle {
	return [NSString stringWithFormat:@"%@-%d", (isTitle ? @"title" : @"pass"), count];
}

@end

// vim:ft=objc
