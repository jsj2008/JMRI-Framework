# JMRI-Framework #

[![Build Status](https://travis-ci.org/rhwood/JMRI-Framework.png)](https://travis-ci.org/rhwood/JMRI-Framework)

*JMRI-Framework* is an Objective-C library for developing [iOS](http://developer.apple.com/devcenter/ios/index.action "iOS Developer Center @ Apple") applications that network with [JMRI](http://jmri.org) software.  Currently, this library only supports iOS and the JMRI [JSON](http://jmri.sourceforge.net/help/en/html/web/JsonServlet.shtml) protocol.

## Installation & Use ##

Fork and install a git submodule for your project. Once version 0.1 is released, this library will be available using [CocoaPods](http://cocoapods.org).

## Framework Dependencies ##

Your .app must link the following frameworks and dylibs

- libicucore.dylib
- CFNetwork.framework
- Security.framework
- Foundation.framework

If you are using Xcode 5, this should be automatic.

You must also include [SocketRocket](https://github.com/square/SocketRocket) in your app. If you use [CocoaPods](http://cocoapods.org), add a [dependency on SocketRocket](http://cocoapods.org/?q=name%3ASocketRocket) to your PodFile. 

## Future Capabilities ##

* Support for JMRI WiThrottles.
* Mac OS X support (This may *just work,* but I have not tested it).
