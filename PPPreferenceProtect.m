#import "PPPreferenceProtect.h"
#import "NSString+Hashes.h"

#define s(z, ...) [NSString stringWithFormat:z, ##__VA_ARGS__]
#define log(x, y, z) if([self.lockedPanes[y][@"shouldLog"] boolValue] || z || (!self.lockedPanes[y][@"shouldLog"] && YES)) { NSLog(@"[libPreferenceProtect] %@", x); }

#define PPSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/libpreferenceprotect.plist"]

static PPPreferenceProtect* preferenceProtect;

@implementation PPPreferenceProtect

@synthesize lockedPanes;

- (id)init {
	if(self = [super init]) {
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

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"Password"] = [password sha1];
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
	log(s(@"Added password for pane %@", name), name, NO);
}

- (BOOL)removePasswordForPaneWithName:(NSString *)name withPassword:(NSString *)password {
	[self reloadPrefs];

	// About to get destroyed so it will never log
	BOOL shouldLog = [self.lockedPanes[name][@"shouldLog"] boolValue];
	if(!self.lockedPanes[name][@"shouldLog"]) { shouldLog = YES; }

	if(!self.lockedPanes[name][@"Password"]) {
		log(s(@"Cannot remove password from pane %@ because it does not exist", name), name, NO);
		return NO;
	}
	if([self.lockedPanes[name][@"Password"] isEqualToString:[password sha1]]) {
		[self.lockedPanes removeObjectForKey:name];

		NSMutableDictionary* newDict = [[NSMutableDictionary alloc] init];
		newDict[@"shouldLog"] = @(shouldLog);
		self.lockedPanes[name] = newDict;
		[self savePrefs:name];
		
		log(s(@"Removed password for pane %@", name), name, shouldLog);
		return YES;
	}
	log(s(@"Wrong password to remove password for pane %@", name), name, NO);
	return NO;
}

- (void)reloadPrefs {
	self.lockedPanes = [[NSMutableDictionary alloc] initWithContentsOfFile:PPSettingsPath];
	if(!self.lockedPanes) {
		self.lockedPanes = [[NSMutableDictionary alloc] init];
		[self.lockedPanes writeToFile:PPSettingsPath atomically:YES];
	}
}

- (void)savePrefs:(NSString *)name {
	if(![self.lockedPanes writeToFile:PPSettingsPath atomically:YES]) {
		log(@"Error saving settings", name, NO);
	}
}

- (BOOL)paneExists:(NSString *)name {
	if([[self.lockedPanes allKeys] containsObject:name]) {
		return YES;
	}
	return NO;
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

	[self savePrefs:name];
}

- (void)setAlertMessage:(NSString *)alertMessage forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"alertMessage"] = alertMessage;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setAlertPlaceholder:(NSString *)placeholder forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"placeholder"] = placeholder;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setCancelButtonTitle:(NSString *)cancelBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"cancelBnTitle"] = cancelBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setEnterButtonHidden:(BOOL)cancelBnHidden forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"enterBnHidden"] = @(cancelBnHidden);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setEnterButtonTitle:(NSString *)enterBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"enterBnTitle"] = enterBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"keyboardType"] = [NSNumber numberWithInt:keyboardType];
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setSecurePassword:(BOOL)securePassword forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"securePassword"] = @(securePassword);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setShouldLog:(BOOL)shouldLog forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"shouldLog"] = @(shouldLog);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setAutoAccept:(BOOL)autoAccept forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"autoAccept"] = @(autoAccept);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotButtonTitle:(NSString *)forgotBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotBnTitle"] = forgotBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

// Forgot button setters

- (void)setForgotEnabled:(BOOL)enabled forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotEnabled"] = @(enabled);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotPassword:(NSString *)password forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotPassword"] = [password sha1];
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotAlertTitle:(NSString *)alertTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotAlertTitle"] = alertTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotAlertMessage:(NSString *)alertMessage forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotAlertMessage"] = alertMessage;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotAlertPlaceholder:(NSString *)placeholder forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotPlaceholder"] = placeholder;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotCancelButtonTitle:(NSString *)cancelBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotCancelBnTitle"] = cancelBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotEnterButtonHidden:(BOOL)cancelBnHidden forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotEnterBnHidden"] = @(cancelBnHidden);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotEnterButtonTitle:(NSString *)enterBnTitle forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotEnterBnTitle"] = enterBnTitle;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotKeyboardType:(UIKeyboardType)keyboardType forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotKeyboardType"] = [NSNumber numberWithInt:keyboardType];
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotSecurePassword:(BOOL)securePassword forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotSecurePassword"] = @(securePassword);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotAutoAccept:(BOOL)autoAccept forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotAutoAccept"] = @(autoAccept);
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

- (void)setForgotEnterPane:(BOOL)enterPane andNotify:(NSString *)notificationId forPaneWithName:(NSString *)name {
	[self reloadPrefs];

	NSMutableDictionary* newDict = [self.lockedPanes[name] mutableCopy];
	if(!newDict) {
		newDict = [[NSMutableDictionary alloc] init];
	}
	newDict[@"forgotCorrectEnterPane"] = @(enterPane);
	newDict[@"forgotCorrectNotify"] = notificationId;
	self.lockedPanes[name] = newDict;

	[self savePrefs:name];
}

@end
