import collections
import sys

grid = [line.strip("\n") for line in sys.stdin]
max_x = len(grid[0])
max_y = len(grid)

portals_by_key = collections.defaultdict(list)
for y in range(2, max_y - 2):
    for x in range(2, max_x - 2):
        if grid[y][x] != ".":
            continue
        if grid[y][x - 1].isupper() and grid[y][x - 2].isupper():
            key = grid[y][x - 2] + grid[y][x - 1]
        elif grid[y][x + 1].isupper() and grid[y][x + 2].isupper():
            key = grid[y][x + 1] + grid[y][x + 2]
        elif grid[y - 1][x].isupper() and grid[y - 2][x].isupper():
            key = grid[y - 2][x] + grid[y - 1][x]
        elif grid[y + 1][x].isupper() and grid[y + 2][x].isupper():
            key = grid[y + 1][x] + grid[y + 2][x]
        else:
            continue
        portals_by_key[key].append((x, y))

aa = list(portals_by_key["AA"])[0]
zz = list(portals_by_key["ZZ"])[0]

portals = {}
for key in portals_by_key:
    if key == "AA" or key == "ZZ":
        continue
    p1, p2 = portals_by_key[key]
    portals[p1] = p2
    portals[p2] = p1

deltas = ((1, 0), (0, 1), (-1, 0), (0, -1))
def adjacent(p):
    global grid, portals, deltas
    adj = []
    x, y = p
    for dx, dy in deltas:
        if grid[y + dy][x + dx] == ".":
            adj.append((x + dx, y + dy))
    if p in portals:
        adj.append(portals[p])
    return adj


queue = collections.deque()
queue.append(aa)
dist = {aa: 0}

while queue:
    p = queue.popleft()
    for q in adjacent(p):
        if q in dist:
            continue
        dist[q] = dist[p] + 1
        queue.append(q)

print(dist[zz])
