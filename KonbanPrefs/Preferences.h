#import <rootless.h>
#import <AltList/ATLApplicationListSelectionController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <Cephei/HBPreferences.h>
#import "NSTask.h"

@interface KONPrefsListController : HBRootListController
    - (void)respring:(id)sender;
@end