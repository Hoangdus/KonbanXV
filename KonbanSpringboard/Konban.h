#import "../headers/SBApplication.h"
#import "../headers/SBApplicationController.h"

@interface FBSceneManager : NSObject
+ (id)sharedInstance;
- (id)sceneWithIdentifier:(NSString *)arg1;
// - (void)_noteSceneMovedToForeground:(id)arg1;
@end

@interface FBSceneWorkspace : NSObject
+ (id)sharedInstance;
@end

@interface _UIContextLayerHostView : UIView
- (id)initWithSceneLayer:(id)arg1;
@end

@interface _UISceneLayerHostContainerView : UIView
- (id)initWithScene:(id)arg1 debugDescription:(id)arg2;
- (void)_setPresentationContext:(id)arg1;
- (void)invalidate;
@end

@interface UIScenePresentationContext : NSObject
- (id)_initWithDefaultValues;
@end

@interface FBSMutableSceneSettings (Private)
- (void)setIdleModeEnabled:(BOOL)arg1;
- (void)setForeground:(BOOL)arg1;
@end

@interface UIApplication(Private)
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface Konban : NSObject

+(SBApplication *)app:(NSString *)bundleID;
+(UIView *)viewFor:(NSString *)bundleID;
+(void)launch:(NSString *)bundleID;
+(void)forceBackgrounded:(BOOL)backgrounded forApp:(SBApplication *)app;
+(void)rehost:(NSString *)bundleID;
+(void)dehost:(NSString *)bundleID;
+(void)setForeground:(SBApplication *)app foregroundvalue:(BOOL)value;
+(id)createLayerHostView:(NSString *)bundleID;
+(FBScene *)getMainSceneForApp:(SBApplication *)application;

@end
