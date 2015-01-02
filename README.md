gamecenter
==========
[![Build Status](https://travis-ci.org/openfl/gamecenter.png)](https://travis-ci.org/openfl/gamecenter)

Apple GameCenter 
Provides an access to gamecenter (iOS, Mac) for OpenFL projects, using a common API.

Installation
------------

    haxelib install gamecenter
    lime rebuild gamecenter ios

Then in a project file add:

    <haxelib name="gamecenter" />

Trouble Shooting
----------------

If you are running on iOS 8.0 or greater you will need to manually enable Sandbox or else Authorization will fail.

In iOS, go to *Settings > Game Center* and manually enable Sandbox.


Development Builds
------------------

Clone the openfl-samples repository:

    git clone https://github.com/openfl/gamecenter

Then follow standard installation steps.

You must run ```lime rebuild gamecenter ios``` after modifying any modification of the native library code.