[![Build Status](https://img.shields.io/travis/openfl/gamecenter.svg?style=flat)](https://travis-ci.org/openfl/gamecenter) [![Haxelib Version](https://img.shields.io/github/tag/openfl/gamecenter.svg?style=flat&label=haxelib)](http://lib.haxe.org/p/gamecenter)

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
