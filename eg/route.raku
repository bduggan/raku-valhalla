#!raku

use Geo::Valhalla;

# Washington Square Park to Central Park, NYC
my ($from-lat, $from-lon, $to-lat, $to-lon) = <40.7308 -73.9973 40.7648 -73.9808>;
my $conf = %*ENV<VALHALLA_CONF> // 'valhalla.json';
my $v = Geo::Valhalla.new: :$conf;
my $res = $v.route:
   locations => [
       { :lat($from-lat), :lon($from-lon), :type<break> },
       { :lat($to-lat),   :lon($to-lon),   :type<break> },
   ],
   costing => 'auto';
say .<instruction> for $res<trip><legs>[0]<maneuvers><>;
say 'time (minutes): ' ~ $res<trip><summary><time> div 60;
say 'distance (km) : ' ~ $res<trip><summary><length>;

