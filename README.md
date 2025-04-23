python-pysmb-srpm
==========-------

Wrapper for SRPM building tools for python-pysmb.

' make getsrc' relies on macros from


Building python-pysmb
===============------

Ideally, install "mock" and use that to build for both RHEL and up,
through 9 and Fedora 40. Run these commands at the top directory.

* make getsrc # Get source tarvalls for all SRPMs

* make # Make all distinct versions using "mock"

Building a compoenent, without "mock" and in the local working system,
can also be done for testing.

* make build

