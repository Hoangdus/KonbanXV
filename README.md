KonbanXV
========

Swipe right for an App.\
An iOS extention(Tweak) that put an app in iOS today view.\
Support iOS from 15 to 16 (newer might still be supporte, iPadOS might not work)

[<img src="https://github.com/Hoangdus/KonbanXV/blob/main/havoc_get_square.png" alt="drawing" width="500"/>](https://havoc.app/package/konbanxv)

How to use
==========
Step 1: Download this tweak from Havoc repo.\
Step 2: Turn it on in setting.\
Step 3: Select the app you want to open in Today view. ex: **BARQ!**.\
Step 4: **Take a shower.**\
Step 5: Return to the Home screen and swipe right and enjoy.

Caviat
=======
Landscape app will not work.\
App that uses the camera might not work. Like the camera app.\
Haven't been tested on iPadOS

Building
========
You need to have [Theos](https://theos.dev/) installed and configured

Build for rootful
```
make package
```

Build for rootless
```
make package THEOS_PACKAGE_SCHEME=rootless
```


Special thanks
==============
**Nepeta** for original Konban\
**nicho1asdev** for updating Konban to iOS 13 and 14

License
========
KonbanXV is licensed under MIT
