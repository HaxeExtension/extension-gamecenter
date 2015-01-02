gamecenter
==========
[![Build Status](https://travis-ci.org/openfl/gamecenter.png)](https://travis-ci.org/openfl/gamecenter)

Provides access to Apple GameCenter (iOS, Mac) for OpenFL projects using a common API.

Installation
------------

    haxelib install gamecenter

Then in a project file add:

    <haxelib name="gamecenter" />

Troubleshooting
----------------

If you are running on iOS 8.0 or greater you will need to manually enable Sandbox or else Authorization will fail.

In iOS, go to *Settings > Game Center* and manually enable Sandbox.


Development Builds
------------------

Clone the gamecenter repository:

    git clone https://github.com/openfl/gamecenter

Tell haxelib where your development copy of gamecenter is installed:

    haxelib dev gamecenter gamecenter

You can build the binaries using "lime rebuild"

    lime rebuild gamecenter ios
