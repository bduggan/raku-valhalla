#!raku

use Valhalla::Native;

# default washington square park to central park
my ($from-lat, $from-lon, $to-lat, $to-lon) = <40.7308 -73.9973 40.7648 -73.9808>;
my $units = 'miles';
my $conf = %*ENV<VALALLA_CONF>;
die "no conf" unless $conf && $conf.IO.e;

my %req =
      locations => [
          { :lat($from-lat), :lon($from-lon), :type<break> },
          { :lat($to-lat),   :lon($to-lon),   :type<break> },
      ],
      :costing<auto>,
      directions_options => { :$units, } ;

my $actor = valhalla_actor_create($conf) or die "failed to create actor from $conf";
say valhalla-route($actor, %req);
valhalla_actor_destroy($actor);
