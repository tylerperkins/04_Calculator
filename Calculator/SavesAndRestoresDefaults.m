#import <Foundation/Foundation.h>
#import "SavesAndRestoresDefaults.h"


/*  Generates the string key corresponding to the given enum value.
*/
NSString* defaultKey( enum DefaultId n ) {
    return [NSString stringWithFormat:@"%@_%02d", appBundleIdentifier(), n];
}


/*  Looks up the "bundle identifier" for this app.
*/
NSString* appBundleIdentifier() {
    return  [[NSBundle mainBundle] bundleIdentifier];
}


/*  Removes all the persisted keys and values in the application domain of
    the given user defaults object.
*/
void clearAppDefaults( NSUserDefaults* defaults ) {
    [defaults setPersistentDomain:[NSDictionary dictionary]
                          forName:appBundleIdentifier()
    ];
}
