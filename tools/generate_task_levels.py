import os
import re
import math
import xml.etree.ElementTree as ET

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MONSTER_DIR = os.path.join(ROOT, "Rook", "Rook", "data", "monster")
TASK_SYSTEM = os.path.join(ROOT, "Rook", "Rook", "data", "lib", "task_system.lua")
OUT = os.path.join(ROOT, "Rook", "Rook", "data", "lib", "task_levels.lua")
WORLD_DIR = os.path.join(ROOT, "Rook", "Rook", "data", "world")
MAX_LEVEL = 100
# >1.0 pushes weak monsters lower and keeps stronger monsters near the top.
LEVEL_CURVE_GAMMA = 1.8
RAT_MONSTER_NAME = "Rat"
DEMON_MONSTER_NAME = "Demon"

# Tuning knobs for additional monster complexity.
ELEMENT_RESIST_WEIGHT = 0.12
ELEMENT_WEAKNESS_WEIGHT = 0.08
IMMUNITY_POINT_WEIGHT = 0.035
SUMMON_BONUS_WEIGHT = 0.18
SPAWNTIME_WEIGHT = 0.25


def load_task_monsters(path):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    m = re.search(r"monsters\s*=\s*{", text)
    if not m:
        return []
    start = text.find("{", m.start())
    end = text.find("}", start)
    if start == -1 or end == -1:
        return []
    block = text[start + 1 : end]
    return re.findall(r'"([^"]+)"', block)


def parse_int(val, default=0):
    try:
        return int(val)
    except Exception:
        return default


def parse_bool(val):
    if val is None:
        return False
    return str(val).strip().lower() in ("1", "true", "yes")


def median(values):
    if not values:
        return 0.0
    ordered = sorted(values)
    mid = len(ordered) // 2
    if len(ordered) % 2 == 0:
        return (ordered[mid - 1] + ordered[mid]) / 2.0
    return ordered[mid]


def parse_elements_modifier(root):
    elements = root.find("elements")
    if elements is None:
        return 1.0

    resistance_points = 0.0
    weakness_points = 0.0

    for element in elements.findall("element"):
        for attr_name, raw_value in element.attrib.items():
            if not attr_name.endswith("Percent"):
                continue
            percent = parse_int(raw_value, 0)
            if percent > 0:
                resistance_points += min(percent, 100) / 100.0
            elif percent < 0:
                weakness_points += min(abs(percent), 100) / 100.0

    modifier = 1.0 + resistance_points * ELEMENT_RESIST_WEIGHT - weakness_points * ELEMENT_WEAKNESS_WEIGHT
    return max(0.70, min(1.50, modifier))


def parse_immunities_modifier(root):
    immunities = root.find("immunities")
    if immunities is None:
        return 1.0

    points = 0.0
    for immunity in immunities.findall("immunity"):
        for key, raw_value in immunity.attrib.items():
            if not parse_bool(raw_value):
                continue

            key_lower = key.lower()
            if key_lower in ("paralyze", "invisible", "lifedrain"):
                points += 1.4
            elif key_lower in ("outfit", "drunk"):
                points += 0.5
            else:
                points += 1.0

    modifier = 1.0 + points * IMMUNITY_POINT_WEIGHT
    return max(1.0, min(1.45, modifier))


def parse_summons(root):
    summons_node = root.find("summons")
    if summons_node is None:
        return 0, []

    max_summons = max(parse_int(summons_node.get("maxSummons"), 0), 0)
    summons = []

    for summon in summons_node.findall("summon"):
        summon_name = summon.get("name")
        if not summon_name:
            continue

        chance = parse_int(summon.get("chance"), 10)
        chance = max(0, min(chance, 100))

        summon_max = parse_int(summon.get("max"), 1)
        if summon_max <= 0:
            summon_max = 1

        summons.append({"name": summon_name, "chance": chance, "max": summon_max})

    return max_summons, summons


def calc_monster_data(path):
    try:
        tree = ET.parse(path)
    except Exception:
        return None

    root = tree.getroot()
    name = root.get("name")
    if not name:
        return None

    max_hp = 0
    health = root.find("health")
    if health is not None:
        max_hp = parse_int(health.get("max"), parse_int(health.get("now"), 0))

    speed = parse_int(root.get("speed"), 0)

    armor = 0
    defense = 0
    heal_per_sec = 0.0
    defenses = root.find("defenses")
    if defenses is not None:
        armor = parse_int(defenses.get("armor"), 0)
        defense = parse_int(defenses.get("defense"), 0)
        for d in defenses.findall("defense"):
            if d.get("name") == "healing":
                interval = max(parse_int(d.get("interval"), 2000), 1)
                chance = parse_int(d.get("chance"), 100)
                minv = parse_int(d.get("min"), 0)
                maxv = parse_int(d.get("max"), minv)
                avg = (abs(minv) + abs(maxv)) / 2.0
                heal_per_sec += avg * (chance / 100.0) / (interval / 1000.0)

    dps = 0.0
    attacks = root.find("attacks")
    if attacks is not None:
        for a in attacks.findall("attack"):
            minv = a.get("min")
            maxv = a.get("max")
            attack = a.get("attack")
            if minv is None and maxv is None and attack is None:
                continue

            interval = max(parse_int(a.get("interval"), 2000), 1)
            chance = parse_int(a.get("chance"), 100)

            if minv is not None or maxv is not None:
                minv = parse_int(minv or 0, 0)
                maxv = parse_int(maxv or minv, minv)
                avg = (abs(minv) + abs(maxv)) / 2.0
            else:
                avg = float(parse_int(attack, 0))

            dps += avg * (chance / 100.0) / (interval / 1000.0)

    toughness = max_hp * (1.0 + armor / 100.0 + defense / 100.0) + heal_per_sec * 20.0
    speed_factor = 1.0 + max(speed - 100, 0) / 1000.0
    offense = dps * 10.0

    elements_modifier = parse_elements_modifier(root)
    immunities_modifier = parse_immunities_modifier(root)
    max_summons, summons = parse_summons(root)

    score = (toughness + offense) * speed_factor
    score *= elements_modifier
    score *= immunities_modifier

    return {
        "name": name,
        "base_score": score,
        "summons": summons,
        "max_summons": max_summons,
    }


def find_best_spawns_file():
    if not os.path.isdir(WORLD_DIR):
        return None

    best_path = None
    best_count = 0

    for dirpath, _, filenames in os.walk(WORLD_DIR):
        for filename in filenames:
            if not filename.lower().endswith(".xml"):
                continue

            path = os.path.join(dirpath, filename)
            try:
                tree = ET.parse(path)
            except Exception:
                continue

            root = tree.getroot()
            if root.tag != "spawns":
                continue

            count = len(root.findall(".//monster"))
            if count > best_count:
                best_count = count
                best_path = path

    return best_path


def load_spawn_stats():
    path = find_best_spawns_file()
    if not path:
        return {}, None

    try:
        tree = ET.parse(path)
    except Exception:
        return {}, None

    root = tree.getroot()
    stats = {}

    for monster in root.findall(".//monster"):
        name = monster.get("name")
        if not name:
            continue

        spawntime = parse_int(monster.get("spawntime"), 60)
        entry = stats.get(name)
        if entry is None:
            stats[name] = {"count": 1, "sum_spawntime": spawntime}
        else:
            entry["count"] += 1
            entry["sum_spawntime"] += spawntime

    for name, entry in stats.items():
        count = max(entry["count"], 1)
        entry["avg_spawntime"] = entry["sum_spawntime"] / count

    return stats, path


def resolve_key_case_insensitive(name, name_index):
    if name in name_index:
        return name
    return name_index.get(name.lower())


def main():
    task_names = load_task_monsters(TASK_SYSTEM)
    if not task_names:
        raise SystemExit("No task monsters found in task_system.lua")

    monster_data = {}
    name_index = {}
    spawn_stats, spawns_path = load_spawn_stats()

    for dirpath, _, filenames in os.walk(MONSTER_DIR):
        for filename in filenames:
            if not filename.lower().endswith(".xml"):
                continue

            path = os.path.join(dirpath, filename)
            data = calc_monster_data(path)
            if not data:
                continue

            monster_data[data["name"]] = data
            name_index[data["name"]] = data["name"]
            name_index[data["name"].lower()] = data["name"]

    spawn_index = {}
    for name in spawn_stats.keys():
        spawn_index[name] = name
        spawn_index[name.lower()] = name

    spawn_time_values = [
        stat.get("avg_spawntime", 0.0)
        for stat in spawn_stats.values()
        if stat.get("avg_spawntime", 0.0) > 0
    ]
    median_spawntime = median(spawn_time_values)

    task_scores = []
    for task_name in task_names:
        resolved_name = resolve_key_case_insensitive(task_name, name_index)
        data = monster_data.get(resolved_name) if resolved_name else None
        base_score = data["base_score"] if data else 0.0

        summon_bonus = 0.0
        if data:
            max_summons = data.get("max_summons", 0)
            for summon in data.get("summons", []):
                summon_name = resolve_key_case_insensitive(summon.get("name", ""), name_index)
                summon_data = monster_data.get(summon_name) if summon_name else None
                if not summon_data:
                    continue

                chance_factor = max(0.05, min(summon.get("chance", 0), 100) / 100.0)
                summon_max = max(1, summon.get("max", 1))
                if max_summons > 0:
                    summon_max = min(summon_max, max_summons)
                summon_max = min(summon_max, 4)

                summon_bonus += summon_data["base_score"] * chance_factor * summon_max

        score = base_score + summon_bonus * SUMMON_BONUS_WEIGHT

        multiplier = 1.0
        spawn_name = resolve_key_case_insensitive(task_name, spawn_index)
        if median_spawntime > 0 and spawn_name in spawn_stats:
            avg_spawntime = spawn_stats[spawn_name].get("avg_spawntime", 0.0)
            if avg_spawntime > median_spawntime:
                ratio = avg_spawntime / median_spawntime
                multiplier = 1.0 + min((ratio - 1.0) * SPAWNTIME_WEIGHT, 0.40)

        task_scores.append((task_name, score * multiplier))

    if spawns_path:
        print(f"Using spawns file: {spawns_path}")
        if median_spawntime > 0:
            print(f"Median spawn time: {median_spawntime:.2f}s")

    score_by_name = {name: score for name, score in task_scores}
    positive_scores = [score for _, score in task_scores if score > 0]
    if not positive_scores:
        positive_scores = [1.0]

    rat_score = score_by_name.get(RAT_MONSTER_NAME, min(positive_scores))
    if rat_score <= 0:
        rat_score = min(positive_scores)

    max_score = max(positive_scores)
    rat_log = math.log(rat_score)
    max_log = math.log(max_score)

    levels = {}
    for name, score in task_scores:
        if score <= 0 or score <= rat_score:
            levels[name] = 1
            continue

        if max_log <= rat_log:
            ratio = 0.0
        else:
            ratio = (math.log(score) - rat_log) / (max_log - rat_log)

        curved = ratio ** LEVEL_CURVE_GAMMA
        level = 2 + int(round(curved * (MAX_LEVEL - 2)))
        levels[name] = max(1, min(MAX_LEVEL, level))

    if DEMON_MONSTER_NAME in levels:
        levels[DEMON_MONSTER_NAME] = MAX_LEVEL

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("-- Auto-generated by tools/generate_task_levels.py\n")
        f.write("TaskSystem = TaskSystem or {}\n")
        f.write("TaskSystem.levels = {\n")
        for name in sorted(levels.keys()):
            f.write(f"  [\"{name}\"] = {levels[name]},\n")
        f.write("}\n")
        f.write(f"TaskSystem.levelsMax = {MAX_LEVEL}\n")

    print(f"Wrote {OUT} with {len(levels)} task levels")


if __name__ == "__main__":
    main()
