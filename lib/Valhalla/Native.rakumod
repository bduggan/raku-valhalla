unit module Valhalla::Native;

use NativeCall;

constant VALHALLA = %?RESOURCES<libraries/valhalla_c>
  // $*PROGRAM.parent.parent.child('resources/libraries').child($*VM.platform-library-name('valhalla_c'.IO));

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
