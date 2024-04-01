# firefly-cl

firefly-cl is a command line tool for MacOs (13.0+) that provides a command line interface for the Adobe Firefly generative API.

It requires access to the Adobe Firefly Services, generally through enterprise agreements. More info at:

-   [Developer Docs](https://developer.adobe.com/firefly-services/docs/firefly-api/)
-   [Adobe Firefly for Enterprise](https://www.adobe.com/creativecloud/business/enterprise/firefly.html)
-   [Adobe Firefly Services](https://developer.adobe.com/firefly-services/)
-   [Adobe Summit Keynote Firefly Services Demo](https://youtu.be/zCWlX9flim0?t=2399)

The project is created and maintained by [Mike Chambers](https://www.mikechambers.com) and is not supported by Adobe.

## Platforms

The project has currently only been tested on MacOS Ventura (13.0) and above.

## Setup

Place the compiled executable somewhere withing your path, and then run with the following command:

```
firefly --help
```

This will print out the latest documentation on how to use.

You must specify your Firefly API id and secret in one of three ways:

1. Pass in via the command line via the `--client-id` and `--client-secret` arguments
2. Specify via `FIREFLY_CLIENT_ID` and `FIREFLY_CLIENT_SECRET`
3. Compiled into the app via _Secrets.swift_ file (see below)

Note, if you do all three, they keys will be used in the order above, with the first found used.

## Usage

Complete usage information can be found via:

```
firefly --help
```

There are only two required arguments:

```
firefly --prompt "Big bang universe explosion, supernova blast, made out of colorful bath soaps, super detailed" --output-dir images/
```

This will generate an image using the specified prompt with default settings, and save it in a file called "firefly-image.jpg" in the images directory (relative to the directory the command was run).

If the output directory does not exist, it will be created. You can specify the name of the generated image using the `--filename` flag. Note that if you generate more that one image at a time, then file names will be automated. Please see the `--help` command for more specifics.

In general, you can reference the [API developer docs](https://developer.adobe.com/firefly-services/docs/firefly-api/guides/api/image_generation/) to view more detailed information on available arguments and parameters.

You can find a list of supported `--style-presets` values, and examples in the [Image Model Style docs](https://developer.adobe.com/firefly-services/docs/firefly-api/guides/concepts/styles/). They can be passed in via their preset id.

## Compiling

The project is a Swift based command line app, currently compiled with Xcode. It should be possible to compile and run cross platform using the [Swift compiler](https://www.swift.org/), although that work has not been done yet.

You may need to update the Signing settings in project settings under Signing & Capabilities.

In order to compile, you must add a Secrets.swift file to the root of the code directory. This file can be used to compile in your API key and secrets, and in general, should not be checked into your version control system.

```
struct Secrets {
	static let fireflyClientId:String? = nil
	static let fireflyClientSecret:String? = nil
}
```

You must include this file, even if you are not including your keys (just set the properties to nil)

You can compile from within xcode or via the command line:

```
xcodebuild -scheme firefly -configuration Debug -derivedDataPath ./DerivedData
```

### Dependencies

The project uses [Swift Argument Parser](https://github.com/apple/swift-argument-parser), which should be configured within the XCode project.

## Todo / Known Issues

-   Remove dependencies on XCode, and enable compilation / running across platforms / operating systems

## Questions, Feature Requests, Feedback

If you have any questions, feature requests, need help, or just want to chat, you can ping me on [Twitter](https://twitter.com/mesh) or via email at [mikechambers@gmail.com](mailto:mikechambers@gmail.com).

You can also log bugs and feature requests on the [issues page](https://github.com/mikechambers/firefly-cl/issues).

## License

Project released under a [MIT License](LICENSE.md).

[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE.md)
