#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIControl.h>
#import <Cephei/HBPreferences.h>
#import "../headers/FBScene.h"

@interface SBTodayViewController : UIViewController

@property (nonatomic, retain) UIView *konHostView;
@property (nonatomic, retain) UIActivityIndicatorView *konSpinnerView;

-(unsigned long long)contentVisibility;

@end

@interface SBFUserAuthenticationController
	- (void)_setAuthState:(long long)arg1;
@end

@interface SBDeviceApplicationSceneHandle
	-(FBScene *)scene;
@end

@interface KonbanSpringboard: NSObject

+(BOOL)isLocked;

@end
