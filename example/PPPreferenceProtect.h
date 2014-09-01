@interface PPPreferenceProtect : NSObject

// Properties
@property (nonatomic, strong) NSMutableDictionary* lockedPanes;

// Methods
+ (instancetype)sharedInstance;
- (void)addPassword:(NSString *)password forPaneWithName:(NSString *)name;
// Returns true if pane name : password combination was correct and it removed
// Verify that you know the password
- (BOOL)removePasswordForPaneWithName:(NSString *)name withPassword:(NSString *)password;
- (BOOL)paneExists:(NSString *)name;

// Setters
- (void)setAlertTitle:(NSString *)alertTitle forPaneWithName:(NSString *)name;
- (void)setAlertMessage:(NSString *)alertMessage forPaneWithName:(NSString *)name;
- (void)setAlertPlaceholder:(NSString *)placeholder forPaneWithName:(NSString *)name;
- (void)setCancelButtonTitle:(NSString *)cancelBnTitle forPaneWithName:(NSString *)name;
- (void)setEnterButtonTitle:(NSString *)enterBnTitle forPaneWithName:(NSString *)name;
- (void)setKeyboardType:(UIKeyboardType)keyboardType forPaneWithName:(NSString *)name;
- (void)setSecurePassword:(BOOL)securePassword forPaneWithName:(NSString *)name;
- (void)setShouldLog:(BOOL)shouldLog forPaneWithName:(NSString *)name;
- (void)setAutoAccept:(BOOL)autoAccept forPaneWithName:(NSString *)name;

@end
