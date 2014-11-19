adb shell rm -rf /sdcard/lovegame/*
adb push $1 /sdcard/lovegame
adb shell am start -S -n "org.love2d.android/.GameActivity"
adb logcat -c
adb logcat | grep "LöveSDL"