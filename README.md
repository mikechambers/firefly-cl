## Firefly Command Line Utility

firefly is a command line app that provides a command line interface for the Adobe Firefly generative API.

### Platforms

This has currently only been tested on MacOS Sonoma (14.0)

### Compiling

In order to compile, you must add a Secrets.swift file that contains your firefly client ID and Secret.

```
struct Secrets {
	static let fireflyClientId:String = "XXXX"
	static let fireflyClientSecret:String = "XXXX"
}
```

These properties will be used to retrieve and manage your auth tokens for calling the Firefly API.

In general, you should not check this file into your version control system.


You can compile from within xcode or via the command line:

```xcodebuild -scheme firefly -configuration Debug -derivedDataPath ./DerivedData```
