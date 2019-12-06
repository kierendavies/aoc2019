import collections
import sys

adj = collections.defaultdict(set)
for line in sys.stdin:
    a, b = line.strip().split(")")
    adj[a].add(b)
    adj[b].add(a)

def dfs(src, dst, visited):
    if src == dst:
        return 0
    for v in adj[src]:
        if v in visited: continue
        visited.add(v)
        d = dfs(v, dst, visited)
        if d is not None:
            return d + 1
    return None

print(dfs("YOU", "SAN", set()) - 2)
