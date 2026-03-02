#!/usr/bin/env python3
import argparse
import datetime
import shutil
import struct
from collections import Counter
from pathlib import Path

START = 0xFE
END = 0xFF
ESC = 0xFD

OTBM_TILE_AREA = 4
OTBM_TILE = 5
OTBM_ITEM = 6
OTBM_HOUSETILE = 14

OTBM_ATTR_TILE_FLAGS = 3
OTBM_ATTR_ITEM = 9

# Item attr ids (from src/item.h / map_chests_compare.py)
ATTR_ACTION_ID = 4
ATTR_UNIQUE_ID = 5
ATTR_TEXT = 6
ATTR_DESC = 7
ATTR_TELE_DEST = 8
ATTR_ITEM = 9
ATTR_DEPOT_ID = 10
ATTR_RUNE_CHARGES = 12
ATTR_HOUSEDOORID = 14
ATTR_COUNT = 15
ATTR_DURATION = 16
ATTR_DECAYING_STATE = 17
ATTR_WRITTENDATE = 18
ATTR_WRITTENBY = 19
ATTR_SLEEPERGUID = 20
ATTR_SLEEPSTART = 21
ATTR_CHARGES = 22
ATTR_CONTAINER_ITEMS = 23
ATTR_NAME = 24
ATTR_ARTICLE = 25
ATTR_PLURALNAME = 26
ATTR_WEIGHT = 27
ATTR_ATTACK = 28
ATTR_DEFENSE = 29
ATTR_EXTRADEFENSE = 30
ATTR_ARMOR = 31
ATTR_HITCHANCE = 32
ATTR_SHOOTRANGE = 33
ATTR_CUSTOM_ATTRIBUTES = 34
ATTR_DECAYTO = 35
ATTR_WRAPID = 36
ATTR_STOREITEM = 37
ATTR_ATTACK_SPEED = 38

ONE_BYTE_ATTRS = {ATTR_COUNT, ATTR_RUNE_CHARGES, ATTR_DECAYING_STATE, ATTR_SHOOTRANGE, ATTR_STOREITEM}
TWO_BYTE_ATTRS = {ATTR_ACTION_ID, ATTR_UNIQUE_ID, ATTR_CHARGES, ATTR_WRAPID, ATTR_DEPOT_ID}
FOUR_BYTE_ATTRS = {
    ATTR_DURATION,
    ATTR_WRITTENDATE,
    ATTR_SLEEPERGUID,
    ATTR_SLEEPSTART,
    ATTR_WEIGHT,
    ATTR_ATTACK_SPEED,
    ATTR_ATTACK,
    ATTR_DEFENSE,
    ATTR_EXTRADEFENSE,
    ATTR_ARMOR,
    ATTR_DECAYTO,
}
ONE_BYTE_SIGNED_ATTRS = {ATTR_HITCHANCE, ATTR_HOUSEDOORID}
STRING_ATTRS = {ATTR_TEXT, ATTR_DESC, ATTR_WRITTENBY, ATTR_NAME, ATTR_ARTICLE, ATTR_PLURALNAME}


def parse_ids(raw: str):
    ids = set()
    for chunk in raw.split(","):
        chunk = chunk.strip()
        if not chunk:
            continue
        ids.add(int(chunk))
    return ids


def parse_tiles(raw: str):
    out = set()
    if not raw:
        return out
    chunks = [c.strip() for c in raw.split(";") if c.strip()]
    for chunk in chunks:
        parts = [p.strip() for p in chunk.split(",")]
        if len(parts) != 3:
            raise ValueError(f"Invalid tile triple: '{chunk}'. Expected format x,y,z;x2,y2,z2")
        out.add((int(parts[0]), int(parts[1]), int(parts[2])))
    return out


def escape_props(props: bytes) -> bytes:
    out = bytearray()
    for b in props:
        if b in (ESC, START, END):
            out.append(ESC)
        out.append(b)
    return bytes(out)


def decode_props(data: bytes, idx: int):
    out = bytearray()
    n = len(data)
    while idx < n:
        b = data[idx]
        if b == ESC:
            idx += 1
            if idx >= n:
                raise ValueError("Malformed OTBM stream: dangling escape byte.")
            out.append(data[idx])
            idx += 1
            continue
        if b == START or b == END:
            break
        out.append(b)
        idx += 1
    return bytes(out), idx


def skip_node(data: bytes, idx: int):
    if idx >= len(data) or data[idx] != START:
        raise ValueError(f"Invalid node start at offset {idx}.")

    depth = 0
    i = idx
    n = len(data)
    while i < n:
        b = data[i]
        if b == ESC:
            i += 2
            continue
        if b == START:
            depth += 1
            i += 2  # skip start marker + node type
            continue
        if b == END:
            depth -= 1
            i += 1
            if depth == 0:
                return i
            continue
        i += 1
    raise ValueError("Malformed OTBM stream: node end not found.")


def _read_u16(buf: bytes, pos: int):
    if pos + 2 > len(buf):
        return None
    return struct.unpack_from("<H", buf, pos)[0]


def _read_u32(buf: bytes, pos: int):
    if pos + 4 > len(buf):
        return None
    return struct.unpack_from("<I", buf, pos)[0]


def _read_u64(buf: bytes, pos: int):
    if pos + 8 > len(buf):
        return None
    return struct.unpack_from("<Q", buf, pos)[0]


def _skip_string(buf: bytes, pos: int):
    ln = _read_u16(buf, pos)
    if ln is None:
        return None
    pos += 2
    if pos + ln > len(buf):
        return None
    return pos + ln


def parse_item_attr_end(buf: bytes, start: int):
    pos = start
    n = len(buf)
    while pos < n:
        attr = buf[pos]
        pos += 1
        if attr == 0:
            return pos

        if attr in ONE_BYTE_ATTRS or attr in ONE_BYTE_SIGNED_ATTRS:
            if pos + 1 > n:
                return None
            pos += 1
            continue

        if attr in TWO_BYTE_ATTRS:
            if pos + 2 > n:
                return None
            pos += 2
            continue

        if attr in FOUR_BYTE_ATTRS:
            if pos + 4 > n:
                return None
            pos += 4
            continue

        if attr == ATTR_TELE_DEST:
            if pos + 5 > n:
                return None
            pos += 5
            continue

        if attr in STRING_ATTRS:
            pos = _skip_string(buf, pos)
            if pos is None:
                return None
            continue

        if attr == ATTR_CUSTOM_ATTRIBUTES:
            count = _read_u64(buf, pos)
            if count is None:
                return None
            pos += 8
            for _ in range(count):
                pos = _skip_string(buf, pos)
                if pos is None or pos >= n:
                    return None
                typ = buf[pos]
                pos += 1
                if typ == 0:
                    continue
                if typ == 1:
                    pos = _skip_string(buf, pos)
                    if pos is None:
                        return None
                    continue
                if typ == 2 or typ == 3:
                    if pos + 8 > n:
                        return None
                    pos += 8
                    continue
                if typ == 4:
                    if pos + 1 > n:
                        return None
                    pos += 1
                    continue
                return None
            continue

        if attr == ATTR_CONTAINER_ITEMS:
            # Should not happen in OTBM_ATTR_ITEM on map tiles, but parse anyway.
            if pos + 4 > n:
                return None
            pos += 4
            continue

        return None

    return None


def parse_inline_item(buf: bytes, start: int, map_version: int):
    if start + 2 > len(buf):
        return None, None
    item_id = _read_u16(buf, start)
    base = start + 2

    candidates = []

    end0 = parse_item_attr_end(buf, base)
    if end0 is not None:
        candidates.append((end0, 0))

    if map_version == 0 and base + 1 <= len(buf):
        end1 = parse_item_attr_end(buf, base + 1)
        if end1 is not None:
            candidates.append((end1, 1))

    if candidates:
        def score(end_pos, used_count):
            boundary_ok = end_pos == len(buf) or buf[end_pos] in (OTBM_ATTR_TILE_FLAGS, OTBM_ATTR_ITEM)
            return (1 if boundary_ok else 0, -used_count, -end_pos)

        best = sorted(candidates, key=lambda c: score(c[0], c[1]), reverse=True)[0]
        return item_id, best[0]

    # Fallback for rare editor formats with no attr-end marker.
    fallback = base
    if map_version == 0 and base + 1 <= len(buf):
        next_after_count = base + 1
        if next_after_count == len(buf) or buf[next_after_count] in (OTBM_ATTR_TILE_FLAGS, OTBM_ATTR_ITEM):
            fallback = next_after_count
    return item_id, fallback


def transform_tile_props(props: bytes, is_house_tile: bool, map_version: int, remove_ids: set, removed: Counter):
    prefix = 2 + (4 if is_house_tile else 0)
    if len(props) < prefix:
        return props

    out = bytearray(props[:prefix])
    pos = prefix
    n = len(props)

    while pos < n:
        attr = props[pos]

        if attr == OTBM_ATTR_TILE_FLAGS:
            if pos + 5 > n:
                out.extend(props[pos:])
                break
            out.extend(props[pos:pos + 5])
            pos += 5
            continue

        if attr == OTBM_ATTR_ITEM:
            item_id, end_pos = parse_inline_item(props, pos + 1, map_version)
            if item_id is None or end_pos is None or end_pos <= pos + 1 or end_pos > n:
                out.extend(props[pos:])
                break

            if item_id in remove_ids:
                removed[item_id] += 1
            else:
                out.extend(props[pos:end_pos])
            pos = end_pos
            continue

        # Unknown tile attr: keep rest untouched to avoid corruption.
        out.extend(props[pos:])
        break

    return bytes(out)


def strip_all_inline_tile_items(props: bytes, is_house_tile: bool, map_version: int):
    prefix = 2 + (4 if is_house_tile else 0)
    if len(props) < prefix:
        return props

    out = bytearray(props[:prefix])
    pos = prefix
    n = len(props)
    while pos < n:
        attr = props[pos]
        if attr == OTBM_ATTR_TILE_FLAGS:
            if pos + 5 > n:
                break
            out.extend(props[pos:pos + 5])
            pos += 5
            continue
        if attr == OTBM_ATTR_ITEM:
            _, end_pos = parse_inline_item(props, pos + 1, map_version)
            if end_pos is None or end_pos <= pos + 1 or end_pos > n:
                # Aggressive fallback: drop the rest of tile-item stream to avoid invalid item bytes.
                break
            pos = end_pos
            continue
        # Preserve unknown tile attrs as-is.
        out.extend(props[pos:])
        break
    return bytes(out)


def transform_node(
    data: bytes,
    idx: int,
    out: bytearray,
    map_version: int,
    remove_ids: set,
    removed: Counter,
    enabled: bool,
    area_base=None,
    remove_tiles=None,
):
    if not enabled:
        return skip_node(data, idx)

    if idx >= len(data) or data[idx] != START:
        raise ValueError(f"Invalid node start at offset {idx}.")
    if idx + 1 >= len(data):
        raise ValueError("Unexpected EOF while reading node type.")

    node_type = data[idx + 1]
    idx += 2

    props, idx = decode_props(data, idx)

    drop_node = False
    new_props = props

    child_area_base = area_base
    clear_this_tile = False

    if node_type == OTBM_TILE_AREA and len(props) >= 5:
        bx = _read_u16(props, 0)
        by = _read_u16(props, 2)
        bz = props[4]
        if bx is not None and by is not None:
            child_area_base = (bx, by, bz)

    if node_type == OTBM_ITEM and len(props) >= 2:
        item_id = _read_u16(props, 0)
        if item_id in remove_ids:
            removed[item_id] += 1
            drop_node = True
    elif node_type == OTBM_TILE or node_type == OTBM_HOUSETILE:
        is_house = node_type == OTBM_HOUSETILE
        if child_area_base and len(props) >= 2:
            tx = props[0]
            ty = props[1]
            tile_xyz = (child_area_base[0] + tx, child_area_base[1] + ty, child_area_base[2])
            if remove_tiles and tile_xyz in remove_tiles:
                clear_this_tile = True

        if clear_this_tile:
            new_props = strip_all_inline_tile_items(props, is_house, map_version)
        else:
            new_props = transform_tile_props(props, is_house, map_version, remove_ids, removed)

    if not drop_node:
        out.append(START)
        out.append(node_type)
        out.extend(escape_props(new_props))

    child_enabled = enabled and not drop_node
    while idx < len(data) and data[idx] == START:
        if clear_this_tile:
            idx = skip_node(data, idx)
            continue
        idx = transform_node(
            data,
            idx,
            out,
            map_version,
            remove_ids,
            removed,
            child_enabled,
            child_area_base,
            remove_tiles,
        )

    if idx >= len(data) or data[idx] != END:
        raise ValueError(f"Malformed OTBM stream near offset {idx}: missing node end.")
    idx += 1

    if not drop_node:
        out.append(END)

    return idx


def get_map_version(data: bytes):
    if len(data) < 6 or data[4] != START:
        raise ValueError("Invalid OTBM: missing root start marker.")
    _, idx = decode_props(data, 6)
    props, _ = decode_props(data, 6)
    if len(props) < 4:
        return 1
    return struct.unpack_from("<I", props, 0)[0]


def main():
    parser = argparse.ArgumentParser(description="Remove selected item IDs from an OTBM map.")
    parser.add_argument("--map", required=True, help="Path to world.otbm")
    parser.add_argument("--ids", required=True, help="Comma-separated item IDs to remove")
    parser.add_argument("--remove-tiles", help="Semicolon-separated xyz triples to clear items on tile, e.g. 32449,31619,7;31979,31562,9")
    parser.add_argument("--out", help="Output OTBM path (default: overwrite --map)")
    parser.add_argument("--no-backup", action="store_true", help="Do not create backup when overwriting input map")
    args = parser.parse_args()

    map_path = Path(args.map)
    if not map_path.exists():
        raise FileNotFoundError(f"Map not found: {map_path}")

    remove_ids = parse_ids(args.ids)
    remove_tiles = parse_tiles(args.remove_tiles)
    if not remove_ids:
        raise ValueError("No item IDs provided.")

    out_path = Path(args.out) if args.out else map_path

    data = map_path.read_bytes()
    if data[:4] not in (b"OTBM", b"\x00\x00\x00\x00"):
        raise ValueError("Unsupported file header: not an OTBM file.")

    map_version = get_map_version(data)
    removed = Counter()

    transformed = bytearray()
    transformed.extend(data[:4])
    idx_after_root = transform_node(
        data,
        4,
        transformed,
        map_version,
        remove_ids,
        removed,
        True,
        None,
        remove_tiles,
    )
    if idx_after_root < len(data):
        transformed.extend(data[idx_after_root:])

    if out_path == map_path and not args.no_backup:
        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup = map_path.with_suffix(map_path.suffix + f".bak_remove_items_{ts}")
        shutil.copy2(map_path, backup)
        print(f"Backup: {backup}")

    out_path.write_bytes(bytes(transformed))

    print(f"Input map:  {map_path}")
    print(f"Output map: {out_path}")
    print(f"Map version: {map_version}")
    print(f"IDs requested: {sorted(remove_ids)}")
    if remove_tiles:
        print(f"Tiles cleared: {sorted(remove_tiles)}")
    print("Removed counts:")
    total = 0
    for item_id in sorted(remove_ids):
        cnt = removed.get(item_id, 0)
        total += cnt
        print(f"  {item_id}: {cnt}")
    print(f"Total removed: {total}")


if __name__ == "__main__":
    main()
