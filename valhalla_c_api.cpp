#include <valhalla/baldr/graphreader.h>
#include <valhalla/baldr/directededge.h>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <string>
#include <cstring>
#include <cstdlib>

using namespace valhalla::baldr;

extern "C" {

struct ValhallaReader {
    GraphReader* reader;
};

struct EdgeData {
    uint32_t speed;      // speed in KPH
    uint32_t length;     // length in meters
    uint64_t graphid;    // packed GraphId
};

// Create a GraphReader from a valhalla.json config file path.
// Returns nullptr on failure.
ValhallaReader* valhalla_reader_create(const char* config_path) {
    try {
        boost::property_tree::ptree pt;
        boost::property_tree::read_json(config_path, pt);
        auto* reader = new GraphReader(pt.get_child("mjolnir"));
        auto* handle = new ValhallaReader{reader};
        return handle;
    } catch (...) {
        return nullptr;
    }
}

void valhalla_reader_destroy(ValhallaReader* handle) {
    if (!handle) return;
    delete handle->reader;
    delete handle;
}

// Returns number of directed edges in the given tile, or -1 on error.
int valhalla_tile_edge_count(ValhallaReader* handle, int level, int tile_id) {
    if (!handle) return -1;
    try {
        GraphId gid(tile_id, level, 0);
        auto tile = handle->reader->GetGraphTile(gid);
        if (!tile) return -1;
        return (int)tile->header()->directededgecount();
    } catch (...) {
        return -1;
    }
}

// Fill edge_out with data for edge index i in the given tile.
// Returns 1 on success, 0 on failure.
int valhalla_tile_get_edge(ValhallaReader* handle, int level, int tile_id, int edge_idx, EdgeData* edge_out) {
    if (!handle || !edge_out) return 0;
    try {
        GraphId gid(tile_id, level, 0);
        auto tile = handle->reader->GetGraphTile(gid);
        if (!tile) return 0;
        if (edge_idx < 0 || (uint32_t)edge_idx >= tile->header()->directededgecount()) return 0;
        const DirectedEdge* edge = tile->directededge((size_t)edge_idx);
        if (!edge) return 0;
        edge_out->speed  = edge->speed();
        edge_out->length = edge->length();
        GraphId eid(tile_id, level, edge_idx);
        edge_out->graphid = eid.value;
        return 1;
    } catch (...) {
        return 0;
    }
}

} // extern "C"
