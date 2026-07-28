unit class Geo::Valhalla;
use Geo::Valhalla::Native;

has $.actor;
has Str $.conf is required;

submethod TWEAK {
  fail "Valhalla configuration file not found at {$!conf}" unless $!conf.IO.e;
  $!actor = valhalla_actor_create($!conf);
}

submethod DESTROY {
  valhalla_actor_destroy($!actor) if $!actor;
}

method route(*%req) {
   valhalla-route($!actor, %req);
}

=begin pod

=head1 NAME

Geo::Valhalla -- Interface to the Valhalla routing engine

=head1 SYNOPSIS

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

=head1 DESCRIPTION

This is a Raku interface to the L<Valhalla|https://github.com/valhalla/valhalla> routing engine.

It provides bindings similar to the L<bindings|https://github.com/valhalla/valhalla/tree/master/src/bindings> available for other languages.

This class provides a somewhat high level OO interface, while L<Geo::Valhalla::Native> provides a lower level functional interface.

This is pre-beta, everything is subject to change!

=head1 EXAMPLES

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

<img width="1156" height="655" alt="Image" src="https://github.com/user-attachments/assets/562e299a-772e-4885-9874-1e2e0500087d" />

=head1 INSTALLATION

Installing Valhalla itself is documented L<here|https://valhalla.github.io/valhalla/building/>.

Once Valhalla is installed, build the native shim with:

  ./make lib

This detects your platform (building C<libvalhalla_c.so> on Linux or
C<libvalhalla_c.dylib> on macOS) and how Valhalla is installed. By default it
links against the shared C<libvalhalla> if one is present, otherwise it links
the static C<libvalhalla.a> into the shim. Either way it discovers Valhalla via
C<pkg-config> (set C<PKG_CONFIG_PATH> if C<libvalhalla.pc> lives somewhere
non-standard).

To force linking the static C<libvalhalla.a> even when a shared library is also
installed — producing a self-contained shim that needs no C<libvalhalla> at
runtime — set:

  VALHALLA_USE_STATIC=1 ./make lib

The static archive is only used at build time; it is never shipped.

Note that this module wraps Valhalla's C++ with a C API, which is similar to mechanisms
used by the other bindings.

=head1 AUTHOR

Brian Duggan

=end pod

