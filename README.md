[![Actions Status](https://github.com/bduggan/raku-valhalla/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-valhalla/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-valhalla/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-valhalla/actions/workflows/macos.yml)

NAME
====

Geo::Valhalla -- Interface to the Valhalla routing engine

SYNOPSIS
========

    use Geo::Valhalla;

    # Washington Square Park to Central Park, NYC
    my ($from-lat, $from-lon, $to-lat, $to-lon) = <40.7308 -73.9973 40.7648 -73.9808>;
    my $v = Geo::Valhalla.new;
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

This class provides a somewhat high level OO interface, while [Geo::Valhalla::Native](Geo::Valhalla::Native) provides a lower level functional interface.

This is pre-beta, everything is subject to change!

EXAMPLES
========

Here is a more complete example of drawing a route between two places, with turn instructions.

    use Geo::Valhalla;
    use Geo::Polyline;
    use Map::Leaflet 'leaf';
    use WebService::Nominatim 'nom';

    my $v = Geo::Valhalla.new: :conf( %*ENV<VALHALLA_CONF> );

    # These return a hash with lat/lon
    my %from = nom.search('Washington Square Park').first;
    my %to = nom.search('Tompkins Square Park').first;

    # Get the route
    my $res = $v.route: locations => [ %from, %to ], costing => 'auto';

    leaf.extra-css = q:to/CSS/;
       .route-label {
          background-color: white;
          border: 2px solid black;
          white-space: nowrap;
       }
    CSS

    my $leg = $res<trip><legs>.first;
    my $points = polyline6-decode $leg<shape>;
    for $leg<maneuvers><> -> $m {
        my $latlng = $points[ $m<begin_shape_index>  ].reverse; # lnglat to latlng
        leaf.create-marker: :$latlng;
        my $icon = leaf.create-div-icon:
            html => ( $m<instruction> // '' ) ~ '<br>'
                    ~ '<b>' ~ ($m<street_names> // '') ~ '</b>',
            className => 'route-label';
        leaf.create-marker: :$latlng, options => %( :$icon );
    }
    leaf.add-geojson: polyline6-to-geojson($res<trip><legs>[0]<shape>), style => { weight => 10 };
    leaf.show;

![directions](https://raw.githubusercontent.com/bduggan/raku-valhalla/images/img/directions.png)

INSTALLATION
============

Installing Valhalla itself is documented [here](https://valhalla.github.io/valhalla/building/).

You will likely need to compile from source to get the .so or .dylib. After this, run `./make-dylib` in this repository.

Note that this module wraps Valhalla's C++ with a C API, which is similar to mechanisms used by the other bindings.

AUTHOR
======

Brian Duggan

