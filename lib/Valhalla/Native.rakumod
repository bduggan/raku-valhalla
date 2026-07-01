unit module Valhalla::Native;

use NativeCall;

my constant VALHALLA = BEGIN {
    my $r = %?RESOURCES<libraries/valhalla_c>;
    my $ok = try { $r.IO ~~ IO::Path && $r.IO.e };
    if $ok {
        $r;
    } else {
        my $name = $*VM.platform-library-name('valhalla_c'.IO);
        my $found;
        for $*PROGRAM.parent, $*PROGRAM.parent.parent -> $base {
            my $p = $base.child('resources/libraries').child($name);
            $found = $p and last if $p.e;
        }
        $found // die "libvalhalla_c not found in resources/libraries — run `./make dylib` first";
    }
}

class ValhallaReader is repr('CPointer') is export { }

class EdgeData is repr('CStruct') is export {
    has uint32 $.speed;    # speed in KPH
    has uint32 $.length;   # length in meters
    has uint64 $.graphid;  # packed GraphId value
}

sub valhalla_reader_create(Str --> ValhallaReader)
    is native(VALHALLA) is export { * }

sub valhalla_reader_destroy(ValhallaReader)
    is native(VALHALLA) is export { * }

sub valhalla_tile_edge_count(ValhallaReader, int32, int32 --> int32)
    is native(VALHALLA) is export { * }

sub valhalla_tile_get_edge(ValhallaReader, int32, int32, int32, EdgeData --> int32)
    is native(VALHALLA) is export { * }
