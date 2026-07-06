unit module Valhalla::Native;

use NativeCall;
use JSON::Fast;

my constant VALHALLA = BEGIN {
    my $r = %?RESOURCES<libraries/valhalla_c>;
    my $ok = try { $r.IO ~~ IO::Path && $r.IO.e };
    if $ok {
        $r;
    } else {
        my $name = $*VM.platform-library-name('valhalla_c'.IO);
        my $p = $*CWD.child('resources/libraries').child($name);
        $p.e ?? $p !! die "libvalhalla_c not found at $p — run `./make dylib` first";
    }
}

class ValhallaReader is repr('CPointer') is export { }

class EdgeData is repr('CStruct') is export {
    has uint32 $.speed;    # speed in KPH
    has uint32 $.length;   # length in meters
    has uint64 $.graphid;  # packed GraphId value
}

sub _valhalla_reader_create(Str --> ValhallaReader)
    is native(VALHALLA) is symbol('valhalla_reader_create') { * }

sub valhalla_reader_create(Str() $config --> ValhallaReader) is export {
    _valhalla_reader_create($config);
}

sub valhalla_reader_destroy(ValhallaReader)
    is native(VALHALLA) is export { * }

sub valhalla_tile_edge_count(ValhallaReader, int32, int32 --> int32)
    is native(VALHALLA) is export { * }

sub valhalla_tile_get_edge(ValhallaReader, int32, int32, int32, EdgeData --> int32)
    is native(VALHALLA) is export { * }

class ValhallaActor is repr('CPointer') is export { }

sub _valhalla_actor_create(Str --> ValhallaActor)
    is native(VALHALLA) is symbol('valhalla_actor_create') { * }

sub valhalla_actor_create(Str() $config --> ValhallaActor) is export {
    _valhalla_actor_create($config);
}

sub valhalla_actor_destroy(ValhallaActor)
    is native(VALHALLA) is export { * }

sub valhalla_actor_route(ValhallaActor, Str --> Pointer[uint8])
    is native(VALHALLA) is export { * }

sub valhalla_free_string(Pointer[uint8])
    is native(VALHALLA) is export { * }

multi sub valhalla-route(ValhallaActor $actor, Str $request-json --> Str) is export {
    my $ptr = valhalla_actor_route($actor, $request-json);
    return Str unless $ptr;
    my $str = nativecast(Str, $ptr);
    my $copy = $str;
    valhalla_free_string($ptr);
    $copy;
}

multi sub valhalla-route(ValhallaActor $actor, %request --> Hash) is export {
    my $resp = valhalla-route($actor, to-json(%request));
    return Hash unless $resp.defined;
    from-json($resp);
}
