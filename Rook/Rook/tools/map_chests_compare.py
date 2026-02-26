import argparse
import struct
import xml.etree.ElementTree as ET
import re
from pathlib import Path

# OTBM constants (from src/iomap.h)
OTBM_ROOTV1 = 1
OTBM_MAP_DATA = 2
OTBM_TILE_AREA = 4
OTBM_TILE = 5
OTBM_ITEM = 6
OTBM_HOUSETILE = 14

OTBM_ATTR_TILE_FLAGS = 3
OTBM_ATTR_ITEM = 9

# Item attribute types (from src/item.h)
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


class Node:
    __slots__ = ("type", "props_begin", "props_end", "parsed", "base_x", "base_y", "base_z", "tile_x", "tile_y", "tile_z")
    def __init__(self, node_type, props_begin):
        self.type = node_type
        self.props_begin = props_begin
        self.props_end = None
        self.parsed = False
        self.base_x = None
        self.base_y = None
        self.base_z = None
        self.tile_x = None
        self.tile_y = None
        self.tile_z = None


class PropStream:
    def __init__(self, data: bytes):
        self.data = data
        self.pos = 0

    def remaining(self):
        return len(self.data) - self.pos

    def read(self, size):
        if self.remaining() < size:
            return None
        out = self.data[self.pos:self.pos + size]
        self.pos += size
        return out

    def read_u8(self):
        b = self.read(1)
        return b[0] if b else None

    def read_u16(self):
        b = self.read(2)
        return struct.unpack("<H", b)[0] if b else None

    def read_u32(self):
        b = self.read(4)
        return struct.unpack("<I", b)[0] if b else None

    def read_u64(self):
        b = self.read(8)
        return struct.unpack("<Q", b)[0] if b else None

    def read_i32(self):
        b = self.read(4)
        return struct.unpack("<i", b)[0] if b else None

    def read_i8(self):
        b = self.read(1)
        return struct.unpack("<b", b)[0] if b else None

    def read_string(self):
        length = self.read_u16()
        if length is None or self.remaining() < length:
            return None
        s = self.data[self.pos:self.pos + length]
        self.pos += length
        return s.decode("utf-8", errors="ignore")

    def skip(self, size):
        if self.remaining() < size:
            return False
        self.pos += size
        return True


def parse_items_xml(path: Path):
    tree = ET.parse(path)
    root = tree.getroot()
    id_to_name = {}
    chest_ids = set()
    stackable_ids = set()
    fluid_ids = set()
    splash_ids = set()
    for item in root.findall("item"):
        try:
            item_id = int(item.get("id"))
        except (TypeError, ValueError):
            continue
        name = item.get("name", "") or ""
        id_to_name[item_id] = name
        lname = name.lower()
        if "chest" in lname or "box" in lname or "crate" in lname:
            chest_ids.add(item_id)
        if item.get("stackable") == "1":
            stackable_ids.add(item_id)
        if item.get("fluidcontainer") == "1" or item.get("fluidContainer") == "1":
            fluid_ids.add(item_id)
        if item.get("splash") == "1":
            splash_ids.add(item_id)
    return id_to_name, chest_ids, stackable_ids, fluid_ids, splash_ids


def parse_actions_xml(path: Path):
    actions = {"action": {}, "unique": {}}

    def add(mapping, key, script):
        if key not in mapping:
            mapping[key] = set()
        mapping[key].add(script)

    def handle_attrs(attrs):
        script = attrs.get("script", "").strip()
        if not script:
            return

        # single ids
        if attrs.get("actionid"):
            try:
                add(actions["action"], int(attrs.get("actionid")), script)
            except ValueError:
                pass
        if attrs.get("uniqueid"):
            try:
                add(actions["unique"], int(attrs.get("uniqueid")), script)
            except ValueError:
                pass

        # ranges (some servers use fromaid/toaid or fromuid/touid)
        if attrs.get("fromaid") and attrs.get("toaid"):
            try:
                start = int(attrs.get("fromaid"))
                end = int(attrs.get("toaid"))
                for aid in range(start, end + 1):
                    add(actions["action"], aid, script)
            except ValueError:
                pass
        if attrs.get("fromuid") and attrs.get("touid"):
            try:
                start = int(attrs.get("fromuid"))
                end = int(attrs.get("touid"))
                for uid in range(start, end + 1):
                    add(actions["unique"], uid, script)
            except ValueError:
                pass

    try:
        tree = ET.parse(path)
        root = tree.getroot()
        for action in root.findall("action"):
            handle_attrs(action.attrib)
    except ET.ParseError:
        # Fallback: regex parse tags (tolerant to malformed XML)
        text = path.read_text(encoding="utf-8", errors="ignore")
        for m in re.finditer(r"<action\\s+[^>]*>", text, flags=re.IGNORECASE):
            tag = m.group(0)
            attrs = dict(re.findall(r"(\\w+)=\"([^\"]*)\"", tag))
            handle_attrs(attrs)

    return actions


def get_current_area(stack):
    for node in reversed(stack):
        if node.base_x is not None:
            return node.base_x, node.base_y, node.base_z
    return None, None, None


def get_current_tile(stack):
    for node in reversed(stack):
        if node.tile_x is not None:
            return node.tile_x, node.tile_y, node.tile_z
    return None, None, None


def get_props(data: bytes, node: Node):
    if node.props_end is None or node.props_end <= node.props_begin:
        return b""
    raw = data[node.props_begin:node.props_end]
    out = bytearray()
    last_escaped = False
    for b in raw:
        if b == 0xFD and not last_escaped:
            last_escaped = True
            continue
        out.append(b)
        last_escaped = False
    return bytes(out)


def parse_item_from_stream(prop: PropStream, map_version, stackable_ids, fluid_ids, splash_ids):
    item_id = prop.read_u16()
    if item_id is None:
        return None
    # mapVersion 0 encodes count for stackable/fluids
    if map_version == 0 and (item_id in stackable_ids or item_id in fluid_ids or item_id in splash_ids):
        if prop.read_u8() is None:
            return None
    action_id = 0
    unique_id = 0
    while True:
        attr = prop.read_u8()
        if attr is None or attr == 0:
            break
        if attr == ATTR_COUNT or attr == ATTR_RUNE_CHARGES or attr == ATTR_DECAYING_STATE or attr == ATTR_SHOOTRANGE or attr == ATTR_STOREITEM:
            prop.read_u8()
        elif attr == ATTR_ACTION_ID:
            action_id = prop.read_u16() or 0
        elif attr == ATTR_UNIQUE_ID:
            unique_id = prop.read_u16() or 0
        elif attr == ATTR_TEXT or attr == ATTR_DESC or attr == ATTR_WRITTENBY or attr == ATTR_NAME or attr == ATTR_ARTICLE or attr == ATTR_PLURALNAME:
            prop.read_string()
        elif attr == ATTR_WRITTENDATE or attr == ATTR_DURATION or attr == ATTR_SLEEPERGUID or attr == ATTR_SLEEPSTART or attr == ATTR_WEIGHT or attr == ATTR_ATTACK_SPEED:
            prop.read_u32()
        elif attr == ATTR_ATTACK or attr == ATTR_DEFENSE or attr == ATTR_EXTRADEFENSE or attr == ATTR_ARMOR or attr == ATTR_DECAYTO:
            prop.read_i32()
        elif attr == ATTR_HITCHANCE:
            prop.read_i8()
        elif attr == ATTR_CHARGES or attr == ATTR_WRAPID:
            prop.read_u16()
        elif attr == ATTR_DEPOT_ID:
            prop.skip(2)
        elif attr == ATTR_HOUSEDOORID:
            prop.skip(1)
        elif attr == ATTR_TELE_DEST:
            prop.skip(5)
        elif attr == ATTR_CUSTOM_ATTRIBUTES:
            size = prop.read_u64()
            if size is None:
                break
            # Best-effort skip: key string + value (type-tagged)
            for _ in range(size):
                key = prop.read_string()
                if key is None:
                    break
                # CustomAttribute serialization: type (uint8) + value
                t = prop.read_u8()
                if t is None:
                    break
                if t == 0:  # nil/blank
                    pass
                elif t == 1:  # string
                    prop.read_string()
                elif t == 2:  # int64
                    prop.read(8)
                elif t == 3:  # double
                    prop.read(8)
                elif t == 4:  # bool
                    prop.read_u8()
        else:
            # Unknown attribute, abort parsing this item
            break
    return item_id, action_id, unique_id


def collect_chests(map_path: Path, items_xml: Path):
    id_to_name, chest_ids, stackable_ids, fluid_ids, splash_ids = parse_items_xml(items_xml)
    data = map_path.read_bytes()
    if data[:4] not in (b"OTBM", b"\x00\x00\x00\x00"):
        raise ValueError("Invalid OTBM header")
    if len(data) < 6 or data[4] != 0xFE:
        raise ValueError("Invalid OTBM: missing root node start")

    results = {}
    map_version = 1

    def parse_node_props(node, stack):
        nonlocal map_version
        props = get_props(data, node)
        if not props:
            node.parsed = True
            return
        prop = PropStream(props)

        if node.type == OTBM_ROOTV1 or node.type == 0:
            # OTBM_root_header
            mv = prop.read_u32()
            if mv is not None:
                map_version = mv
            # width/height/items versions (skip)
            prop.read_u16()
            prop.read_u16()
            prop.read_u32()
            prop.read_u32()
            node.parsed = True
            return

        if node.type == OTBM_TILE_AREA:
            bx = prop.read_u16()
            by = prop.read_u16()
            bz = prop.read_u8()
            node.base_x, node.base_y, node.base_z = bx, by, bz
            node.parsed = True
            return

        if node.type in (OTBM_TILE, OTBM_HOUSETILE):
            tx = prop.read_u8()
            ty = prop.read_u8()
            if tx is None or ty is None:
                node.parsed = True
                return
            base_x, base_y, base_z = get_current_area(stack)
            if base_x is None:
                node.parsed = True
                return
            node.tile_x = base_x + tx
            node.tile_y = base_y + ty
            node.tile_z = base_z
            if node.type == OTBM_HOUSETILE:
                prop.read_u32()  # house id

            # tile attributes
            while True:
                attr = prop.read_u8()
                if attr is None:
                    break
                if attr == OTBM_ATTR_TILE_FLAGS:
                    prop.read_u32()
                elif attr == OTBM_ATTR_ITEM:
                    item = parse_item_from_stream(prop, map_version, stackable_ids, fluid_ids, splash_ids)
                    if item:
                        item_id, aid, uid = item
                        if item_id in chest_ids:
                            results[(node.tile_x, node.tile_y, node.tile_z)] = (item_id, aid, uid)
                else:
                    break
            node.parsed = True
            return

        if node.type == OTBM_ITEM:
            item = parse_item_from_stream(PropStream(props), map_version, stackable_ids, fluid_ids, splash_ids)
            if item:
                item_id, aid, uid = item
                if item_id in chest_ids:
                    x, y, z = get_current_tile(stack)
                    if x is not None:
                        results[(x, y, z)] = (item_id, aid, uid)
            node.parsed = True
            return

        node.parsed = True

    # streaming parse
    i = 4
    root = Node(data[i + 1], i + 2)
    stack = [root]
    i = i + 2
    while i < len(data):
        b = data[i]
        if b == 0xFE:  # START
            parent = stack[-1]
            if not parent.parsed:
                parent.props_end = i
                parse_node_props(parent, stack)
            if i + 1 >= len(data):
                raise ValueError("Invalid OTBM: unexpected EOF after START")
            child = Node(data[i + 1], i + 2)
            stack.append(child)
            i += 2
            continue
        if b == 0xFF:  # END
            node = stack.pop()
            if not node.parsed:
                node.props_end = i
                parse_node_props(node, stack)
            i += 1
            if not stack:
                break
            continue
        if b == 0xFD:  # ESCAPE
            i += 2
            continue
        i += 1

    return results, id_to_name, chest_ids


def write_report(out_path: Path, ots_map, tvp_map, ots_items, tvp_items, ots_actions_xml, tvp_actions_xml):
    ots_data, ots_names, ots_chest_ids = collect_chests(ots_map, ots_items)
    tvp_data, tvp_names, tvp_chest_ids = collect_chests(tvp_map, tvp_items)
    ots_actions = parse_actions_xml(ots_actions_xml)
    tvp_actions = parse_actions_xml(tvp_actions_xml)

    ots_positions = set(ots_data.keys())
    tvp_positions = set(tvp_data.keys())
    both = sorted(ots_positions & tvp_positions)
    only_ots = sorted(ots_positions - tvp_positions)
    only_tvp = sorted(tvp_positions - ots_positions)

    def fmt(pos):
        return f"{pos[0]},{pos[1]},{pos[2]}"

    with out_path.open("w", encoding="utf-8") as f:
        f.write(f"OTS map: {ots_map}\n")
        f.write(f"TVP map: {tvp_map}\n")
        f.write(f"OTS chest IDs (name contains chest/box/crate): {sorted(ots_chest_ids)}\n")
        f.write(f"TVP chest IDs (name contains chest/box/crate): {sorted(tvp_chest_ids)}\n\n")

        f.write("=== Positions with chests in BOTH maps (show OTS scripts only) ===\n")
        for pos in both:
            oid, oa, ou = ots_data[pos]
            tid, ta, tu = tvp_data[pos]
            # resolve scripts from actionid/uniqueid (prefer UID)
            ots_scripts = set()
            tvp_scripts = set()
            if ou and ou in ots_actions["unique"]:
                ots_scripts |= ots_actions["unique"][ou]
            if not ots_scripts and oa and oa in ots_actions["action"]:
                ots_scripts |= ots_actions["action"][oa]
            if tu and tu in tvp_actions["unique"]:
                tvp_scripts |= tvp_actions["unique"][tu]
            if not tvp_scripts and ta and ta in tvp_actions["action"]:
                tvp_scripts |= tvp_actions["action"][ta]

            if not ots_scripts:
                continue
            common = ots_scripts

            f.write(f"pos={fmt(pos)}\n")
            f.write(f"  /teleport {pos[0]} {pos[1]} {pos[2]}\n")
            f.write(f"  ots: itemid={oid} name={ots_names.get(oid,'')} aid={oa} uid={ou}\n")
            f.write(f"  tvp: itemid={tid} name={tvp_names.get(tid,'')} aid={ta} uid={tu}\n")
            f.write(f"  scripts: {', '.join(sorted(common))}\n")

        # (omit OTS-only / TVP-only sections per request)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--ots-map", required=True)
    parser.add_argument("--tvp-map", required=True)
    parser.add_argument("--ots-items", required=True)
    parser.add_argument("--tvp-items", required=True)
    parser.add_argument("--ots-actions", required=True)
    parser.add_argument("--tvp-actions", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()

    write_report(
        Path(args.out),
        Path(args.ots_map),
        Path(args.tvp_map),
        Path(args.ots_items),
        Path(args.tvp_items),
        Path(args.ots_actions),
        Path(args.tvp_actions),
    )


if __name__ == "__main__":
    main()
