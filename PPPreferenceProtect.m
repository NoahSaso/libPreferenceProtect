#import "PPPreferenceProtect.h"
#import "NSString+Hashes.h"

#define s(z, ...) [NSString stringWithFormat:z, ##__VA_ARGS__]
#define log(x, y, z) if([self.lockedPanes[y][@"shouldLog"] boolValue] || z) { NSLog(@"[libPreferenceProtect] %@", x); }

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

@end
