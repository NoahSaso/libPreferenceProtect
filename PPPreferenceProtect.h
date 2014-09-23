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
// May want to use if auto accept is turned on
- (void)setEnterButtonHidden:(BOOL)cancelBnHidden forPaneWithName:(NSString *)name;
- (void)setEnterButtonTitle:(NSString *)enterBnTitle forPaneWithName:(NSString *)name;
- (void)setKeyboardType:(UIKeyboardType)keyboardType forPaneWithName:(NSString *)name;
- (void)setSecurePassword:(BOOL)securePassword forPaneWithName:(NSString *)name;
- (void)setShouldLog:(BOOL)shouldLog forPaneWithName:(NSString *)name;
- (void)setAutoAccept:(BOOL)autoAccept forPaneWithName:(NSString *)name;
- (void)setForgotButtonTitle:(NSString *)forgotBnTitle forPaneWithName:(NSString *)name;

// Forgot button setters
- (void)setForgotEnabled:(BOOL)enabled forPaneWithName:(NSString *)name;
- (void)setForgotPassword:(NSString *)password forPaneWithName:(NSString *)name;
- (void)setForgotAlertTitle:(NSString *)alertTitle forPaneWithName:(NSString *)name;
- (void)setForgotAlertMessage:(NSString *)alertMessage forPaneWithName:(NSString *)name;
- (void)setForgotAlertPlaceholder:(NSString *)placeholder forPaneWithName:(NSString *)name;
- (void)setForgotCancelButtonTitle:(NSString *)cancelBnTitle forPaneWithName:(NSString *)name;
// May want to use if auto accept is turned on
- (void)setForgotEnterButtonHidden:(BOOL)cancelBnHidden forPaneWithName:(NSString *)name;
- (void)setForgotEnterButtonTitle:(NSString *)enterBnTitle forPaneWithName:(NSString *)name;
- (void)setForgotKeyboardType:(UIKeyboardType)keyboardType forPaneWithName:(NSString *)name;
- (void)setForgotSecurePassword:(BOOL)securePassword forPaneWithName:(NSString *)name;
- (void)setForgotAutoAccept:(BOOL)autoAccept forPaneWithName:(NSString *)name;
// You can set enterPane to false, but still receive a notification
// so you can prompt to change the password
- (void)setForgotEnterPane:(BOOL)enterPane andNotify:(NSString *)notificationId forPaneWithName:(NSString *)name;

@end
