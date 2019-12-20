require 'set'

DELTAS = [[1, 0], [0, 1], [-1, 0], [0, -1]]

GRID = ARGF.each_line.map(&:chomp).to_a
START = GRID.each_with_index.map do |line, y|
    if x = line.index(?@)
        [x, y]
    end
end.find(&:itself)
ALL_KEYS = GRID.flat_map { |line| line.scan(/[a-z]/) }.to_set

def reachable_keys(start, have_keys)
    reachable = {}
    queue = [start]
    dist = {start => 0}

    until queue.empty?
        pos = queue.shift
        x, y = pos
        DELTAS.each do |dx, dy|
            new_pos = [x+dx, y+dy]
            next if dist.include?(new_pos)

            c = GRID[y+dy][x+dx]
            next if c == ?#
            next if c =~ /[A-Z]/ && !have_keys.include?(c.downcase)

            if c =~ /[a-z]/ && !have_keys.include?(c)
                reachable[c] = [new_pos, dist[pos] + 1]
            end

            dist[new_pos] = dist[pos] + 1
            queue << [x+dx, y+dy]
        end
    end

    reachable
end

def shortest_all_keys(start, keys)
    return 0 if keys == ALL_KEYS
    shortest = Float::INFINITY
    reachable_keys(start, keys).each_pair do |key, (pos, dist)|
        d = dist + shortest_all_keys(pos, keys | Set[key])
        if d < shortest
            shortest = d
        end
    end
    shortest
end

puts shortest_all_keys(START, Set.new)
