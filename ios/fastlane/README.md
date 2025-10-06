fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Upload existing IPA to TestFlight

### ios submit_appstore

```sh
[bundle exec] fastlane ios submit_appstore
```

Submit latest processed build to App Store

### ios release_app

```sh
[bundle exec] fastlane ios release_app
```

Upload IPA to TestFlight and submit to App Store review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
