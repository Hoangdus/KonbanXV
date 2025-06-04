#import "Konban.h"

@implementation Konban

+(SBApplication *)app:(NSString *)bundleID {
    return [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleID];
}

//Got it mostly working now, keyboard is still probably not rendering(haven't seen it in testing tho)
+(UIView *)viewFor:(NSString *)bundleID {
    [Konban launch:bundleID];
    SBApplication *app = [Konban app:bundleID];
    [Konban forceBackgrounded:NO forApp:app];
    [Konban setForeground:app foregroundvalue:YES];

    return [Konban createLayerHostView:bundleID];
}

+(void)launch:(NSString *)bundleID {
  [[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:YES]; // When launching the app suspended, it doesn't appear for the user or even show in switcher
}

//_setContentState got axed after iOS 14 for some fucking reason

+(void)setForeground:(SBApplication *)app foregroundvalue:(BOOL)value{
  // [scene _setContentState:2]; // 2 == ready, 1 == preparing, 0 == not ready
  FBScene *scene = [Konban getMainSceneForApp:app];
  FBSMutableSceneSettings *sceneSettings = [[scene settings] mutableCopy];//ios 15 fix
  [sceneSettings setForeground:value]; // This is important for the view to be interactable.
  [scene updateSettings:sceneSettings withTransitionContext:nil]; // Enact the changes made
  NSLog(@"[Konban] setForeground scene state %lu", scene.contentState);
  NSLog(@"[Konban] %s", "set foreground success");
}

+(void)forceBackgrounded:(BOOL)backgrounded forApp:(SBApplication *)app {
  FBScene *scene = [Konban getMainSceneForApp:app];
  FBSMutableSceneSettings *sceneSettings = [[scene settings] mutableCopy]; //ios 15 fix
  [sceneSettings setBackgrounded:backgrounded];
  [scene updateSettings:sceneSettings withTransitionContext:nil];
  NSLog(@"[Konban] forceBackgrounded scene state %lu", scene.contentState);
  NSLog(@"[Konban] %s", "force backgrounded success");
}

+(id)createLayerHostView:(NSString *)bundleID { // This is the new implementation to get the view instead of getting it via a FBSceneHostManager which was the old way.
  SBApplication *app = [Konban app:bundleID];
  FBScene *scene = [Konban getMainSceneForApp:app];
  _UISceneLayerHostContainerView *layerHostView=[[objc_getClass("_UISceneLayerHostContainerView") alloc] initWithScene:scene debugDescription:nil]; //updated for ios 15
  [layerHostView _setPresentationContext:[[objc_getClass("UIScenePresentationContext") alloc] _initWithDefaultValues]];
  NSLog(@"[Konban] createLayerHostView scene state %lu", scene.contentState);
  NSLog(@"[Konban] %s", "createLayerHostView success");
  return layerHostView;
}

+(void)rehost:(NSString *)bundleID { //not sure why this doesn't get called
    SBApplication *app = [Konban app:bundleID];
    [Konban launch:bundleID];
    [Konban forceBackgrounded:NO forApp:app];
    [Konban setForeground:app foregroundvalue:YES];
    NSLog(@"[Konban] %s", "rehost success");

}

+(void)dehost:(NSString *)bundleID {
    SBApplication *app = [Konban app:bundleID];
    [Konban forceBackgrounded:YES forApp:app];
    [Konban setForeground:app foregroundvalue:NO];
    NSLog(@"[Konban] %s", "dehost success");
}

+ (FBScene *)getMainSceneForApp:(SBApplication *)app { //updated for iOS 15 (fuck my life)

    //Not sure why Apple decided to move everything that is used to be in FBSceneManager to a whole new fucking class. Took me a while to figure out why it crash. But this work now  
    FBSceneManager *manager = [%c(FBSceneManager) sharedInstance];
    FBSceneWorkspace *workspace = MSHookIvar<FBSceneWorkspace *>(manager, "_workspace");
    NSDictionary *scenes = MSHookIvar<NSDictionary *>(workspace, "_allScenesByID");

    for(NSString *identifier in [scenes allKeys]){
        if([identifier containsString:app.bundleIdentifier]){
            if ([scenes[identifier] isKindOfClass:[%c(FBScene) class]]) {
                // NSLog(@"[Konban] returning %@",identifier);
                return scenes[identifier];
            }
        }
    }
    return nil;
}

@end
