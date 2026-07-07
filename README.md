[![Actions Status](https://github.com/bduggan/raku-valhalla/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-valhalla/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-valhalla/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-valhalla/actions/workflows/macos.yml)

NAME
====

Valhalla -- Interface to the Valhalla routing engine

SYNOPSIS
========

    use Valhalla;

    # Washington Square Park to Central Park, NYC
    my ($from-lat, $from-lon, $to-lat, $to-lon) = <40.7308 -73.9973 40.7648 -73.9808>;
    my $v = Valhalla.new;
    my $res = $v.route:
       locations => [
           { :lat($from-lat), :lon($from-lon), :type<break> },
           { :lat($to-lat),   :lon($to-lon),   :type<break> },
       ],
       costing => 'auto';
    say .<instruction> for $res<trip><legs>[0]<maneuvers><>;
    say 'time (minutes): ' ~ $res<trip><summary><time> div 60;
    say 'distance (km) : ' ~ $res<trip><summary><length>;

Output:

    Drive northwest on Washington Square North.
    Turn right onto 6th Avenue/Avenue of the Americas.
    Turn left onto Greenwich Avenue.
    Turn right onto 8th Avenue.
    Turn left onto West 15th Street.
    Turn right onto NY 9A North/11th Avenue/Joe DiMaggio Highway.
    Keep left to take NY 9A North/12th Avenue/Joe DiMaggio Highway.
    Take exit 7 on the right toward West 56th Street/West 57th Street.
    Turn right onto Broadway.
    Turn left onto West 56th Street.
    Your destination is on the right.
    time (minutes): 13
    distance (km) : 6.731

DESCRIPTION
===========

This is a Raku interface to the [Valhalla](https://github.com/valhalla/valhalla) routing engine.

It provides bindings similar to the [bindings](https://github.com/valhalla/valhalla/tree/master/src/bindings) available for other languages.

This class provides a somewhat high level OO interface, while [Valhalla::Native](Valhalla::Native) provides a lower level functional interface.

This is pre-beta, everything is subject to change!

INSTALLATION
============

Valhalla provides a C++ API. This module wraps that into a C API and then uses Nativecall. Installation varies depending on the system but in general the only prerequisite should be the existence of libvalhalla.so, libvalhalla.dylib or however shared libraries are named on your system. The github actions for this repository verify a complete installation, so that can be used as a point of reference if all else fails.

AUTHOR
======

Brian Duggan

