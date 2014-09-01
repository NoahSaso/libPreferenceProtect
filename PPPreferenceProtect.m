#import "PPPreferenceProtect.h"
#import "NSString+Hashes.h"

#define s(z, ...) [NSString stringWithFormat:z, ##__VA_ARGS__]
#define log(z) if(self.shouldLog) { NSLog(@"[libPreferenceProtect] %@", z); }

#define PPSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/libpreferenceprotect.plist"]

static PPPreferenceProtect* preferenceProtect;

@implementation PPPreferenceProtect

// Customize alert properties
//@synthesize customAlertTitle, customAlertMessage, customAlertCancelButtonTitle, customAlertEnterButtonTitle, customKeyboardType;
// Other
@synthesize lockedPanes/*, securePassword, shouldLog, */;

- (id)init {
	if(self = [super init]) {

		/*
		self.securePassword = YES;
		self.shouldLog = NO;

		self.customAlertMessage = @"Enter Password:";
		self.customAlertCancelButtonTitle = @"Cancel";
		self.customAlertEnterButtonTitle = @"Enter";
		self.customKeyboardType = UIKeyboardTypeDefault;
		*/

		[self reloadPrefs];

	}
	return self;
}

+ (instancetype)sharedInstance {
	if(!preferenceProtect) {
		preferenceProtect = [[PPPreferenceProtect alloc] init];
	}
	return preferenceProtect;
}

- (void)addPassword:(NSString *)password forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSDictionary* newDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[password sha1]] forKeys:[NSArray arrayWithObject:@"Password"]];
	self.lockedPanes[name] = newDict;

	[self savePrefs];
	log(s(@"Added password for pane %@", name));
}

- (BOOL)removePasswordForPaneWithName:(NSString *)name withPassword:(NSString *)password {
	[self reloadPrefs];
	if(!self.lockedPanes[name][@"Password"]) {
		log(s(@"Cannot remove password from pane %@ because it does not exist", name));
		return NO;
	}
	if([self.lockedPanes[name][@"Password"] isEqualToString:[password sha1]]) {
		[self.lockedPanes removeObjectForKey:name];
		[self savePrefs];
		log(s(@"Removed password for pane %@", name));
		return YES;
	}
	log(s(@"Wrong password to remove password for pane %@", name));
	return NO;
}

- (void)reloadPrefs {
	self.lockedPanes = [[NSMutableDictionary alloc] initWithContentsOfFile:PPSettingsPath];
	if(!self.lockedPanes) {
		self.lockedPanes = [[NSMutableDictionary alloc] init];
		[self.lockedPanes writeToFile:PPSettingsPath atomically:YES];
	}
}

- (void)savePrefs {
	if(![self.lockedPanes writeToFile:PPSettingsPath atomically:YES]) {
		log(@"Error saving settings");
	}
}

// Setters

- (void)setAlertTitle:(NSString *)alertTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"alertTitle"] = alertTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

- (void)setAlertMessage:(NSString *)alertMessage forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"alertMessage"] = alertMessage;
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

- (void)setCancelButtonTitle:(NSString *)cancelBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"cancelBnTitle"] = cancelBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

- (void)setEnterButtonTitle:(NSString *)enterBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"enterBnTitle"] = enterBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"keyboardType"] = [NSNumber numberWithInt:keyboardType];
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

- (void)setSecurePassword:(BOOL)securePassword forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"securePassword"] = @(securePassword);
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

- (void)setShouldLog:(BOOL)shouldLog forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"shouldLog"] = @(shouldLog);
	self.lockedPanes[name] = newDict;

	[self savePrefs];
}

@end
