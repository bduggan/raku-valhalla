#!raku

use Geo::Valhalla;
use Map::Leaflet 'leaf';
use Geo::Polyline;

# Washington Square Park to Union Square, NYC
my ($from-lat, $from-lon, $to-lat, $to-lon) = <40.7308 -73.9973 40.7359 -73.9911>;
my $conf = %*ENV<VALHALLA_CONF>;
my $v = Geo::Valhalla.new: :$conf;
my $res = $v.route:
   locations => [
       { :lat($from-lat), :lon($from-lon), :type<break> },
       { :lat($to-lat),   :lon($to-lon),   :type<break> },
   ],
   costing => 'pedestrian';

leaf.extra-css = q:to/CSS/;
   .route-label {
      background-color: #fbf7ec;
      color: #2c3648;
      border: 1px solid #c9c1a8;
      padding: 4px 8px;
      border-radius: 4px;
      font: 14px/1.2 sans-serif;
      white-space: nowrap;
      width: auto !important;
      height: auto !important;
      box-shadow: 0 2px 5px rgba(0,0,0,0.25);
   }
   .route-label b {
      color: #a0421a;
   }
CSS

my $points = polyline6-decode $res<trip><legs>[0]<shape>;
for $res<trip><legs>[0]<maneuvers><> -> $m {
    my $shape-index = $m<begin_shape_index>;
    my $shape-index-end = $m<end_shape_index>;
    my $shape = $points[$shape-index .. $shape-index-end];
    leaf.add-geojson: { type => 'Feature', geometry => { type => 'LineString', coordinates => $shape.map({ [.[0], .[1]] }) } }, style => { weight => 10 };
    my $street = ($m<street_names> // []).join(' / ');
    my $instruction = $m<instruction>;
    my $label = $street
        ?? '<b>' ~ $street ~ '</b><br>' ~ $instruction
        !! $instruction;
    #choose a point
    my $chosen = $shape[0];
    my ($lon, $lat) = $chosen;
    my $icon = leaf.create-div-icon:
        html => $label,
        className => 'route-label',
        iconSize => 'auto';
    leaf.create-marker: latlng => [$lat, $lon];
    leaf.create-marker: latlng => [$lat, $lon], options => %( icon => $icon );
}
leaf.add-geojson: polyline6-to-geojson($res<trip><legs>[0]<shape>), style => { weight => 10 };
leaf.show;
