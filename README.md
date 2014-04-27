# JMRI-Framework #

[![Build Status](https://services01.alexandriasoftware.com/buildStatus/icon?job=JMRI_Framework)](https://services01.alexandriasoftware.com/job/JMRI_Framework/)

[![Build Status](https://travis-ci.org/rhwood/JMRI-Framework.png)](https://travis-ci.org/rhwood/JMRI-Framework)

*JMRI-Framework* is an Objective-C library for developing [iOS](http://developer.apple.com/devcenter/ios/index.action "iOS Developer Center @ Apple") applications that network with [JMRI](http://jmri.org) software.  Currently, this library only supports iOS and the JMRI [JSON](http://jmri.sourceforge.net/help/en/html/web/JsonServlet.shtml) protocol.

## Installation & Use ##

*Forthcoming, once I recall my notes on how I use this*

## Framework Dependencies ##

Your .app must link the following frameworks and dylibs

- libicucore.dylib
- CFNetwork.framework
- Security.framework
- Foundation.framework

If you are using Xcode 5, this should be automatic.

## Future Capabilities ##

* Support for JMRI WiThrottles.
* Mac OS X support (This may *just work,* but I have not tested it).
