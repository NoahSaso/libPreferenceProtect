libPreferenceProtect
====================

A simple library for Objective-C to protect preference panes

Example Usage
=============

1. Add "libpreferenceprotect" to your control "Depends" section

2. Add code
```objc
#import "PPPreferenceProtect.h"
[[%c(PPPreferenceProtect) sharedInstance] addPassword:@"123" forPaneWithName:@"Wi-Fi"];
[[%c(PPPreferenceProtect) sharedInstance] setKeyboardType:UIKeyboardTypeNumberPad forPaneWithName:@"Wi-Fi"];
```

Be awesome
