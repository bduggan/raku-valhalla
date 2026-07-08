#!raku

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
