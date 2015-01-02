[![Stories in Ready](https://badge.waffle.io/openfl/gamecenter.png?label=ready)](https://waffle.io/openfl/gamecenter)
[![Build Status](https://travis-ci.org/openfl/gamecenter.png)](https://travis-ci.org/openfl/gamecenter)
GameCenter
==========

Provides access to Apple GameCenter (iOS, Mac) for OpenFL projects using a common API.


Installation
============

You can easily install GameCenter using haxelib:

    haxelib install gamecenter

To add it to a Lime or OpenFL project, add this to your project file:

    <haxelib name="gamecenter" />


Troubleshooting
===============

If you are running on iOS 8.0 or greater you will need to manually enable Sandbox or else Authorization will fail.

In iOS, go to *Settings > Game Center* and manually enable Sandbox.


Development Builds
==================

Clone the GameCenter repository:

    git clone https://github.com/openfl/gamecenter

Tell haxelib where your development copy of GameCenter is installed:

    haxelib dev gamecenter gamecenter

You can build the binaries using "lime rebuild"

    lime rebuild gamecenter ios

To return to release builds:

    haxelib dev gamecenter
