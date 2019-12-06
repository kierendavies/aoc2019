import collections
import sys

orbiters = collections.defaultdict(set)
for line in sys.stdin:
    a, b = line.strip().split(")")
    orbiters[a].add(b)

def orbit_count(centre):
    if not orbiters[centre]:
        return (0, 1)

    orbits = 0
    objects = 1
    for obj in orbiters[centre]:
        sub_orbits, sub_objects = orbit_count(obj)
        orbits += sub_orbits
        orbits += sub_objects
        objects += sub_objects
    return (orbits, objects)

print(orbit_count("COM")[0])
