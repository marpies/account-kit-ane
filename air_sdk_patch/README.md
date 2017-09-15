** Note: The patch is not needed since AIR 27 **

List of modifications:

* `runtimeClasses.jar` - removed compiled AppCompat resources
* `adt.jar` - added `--no-version-vectors` to `aapt` tool when generating APK, enables support for vector resources on Android 4