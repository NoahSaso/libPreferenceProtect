libPreferenceProtect
====================

A simple library for Objective-C to protect preference panes

Example Usage
=============

1. Add "libpreferenceprotect" to your control "Depends" section
```makefile
Depends: mobilesubstrate, libpreferenceprotect
```

2. Add code
```objc
#import "PPPreferenceProtect.h"
[[%c(PPPreferenceProtect) sharedInstance] addPassword:@"123" forPaneWithName:@"Wi-Fi"];
[[%c(PPPreferenceProtect) sharedInstance] setKeyboardType:UIKeyboardTypeNumberPad forPaneWithName:@"Wi-Fi"];
```

Be awesome

Credit
======

NSString+Hashes: https://github.com/mspasov/NSString-Hashes

UIAlertView+IABlocks: https://github.com/Innovattic/UIKit-Blocks
