#include <cassert>
#include <iostream>
#include <queue>
#include <set>
#include <string>
#include <utility>
#include <vector>
using namespace std;

#define OP_ADD 1
#define OP_MULT 2
#define OP_INPUT 3
#define OP_OUTPUT 4
#define OP_JT 5
#define OP_JF 6
#define OP_LT 7
#define OP_EQ 8
#define OP_CHREL 9
#define OP_HALT 99

#define MODE_POS 0
#define MODE_IMM 1
#define MODE_REL 2

#define NUM_AMPS 5
#define PHASE_OFFSET 5

typedef long long m_t;

const int num_params[] = {
    0, // does not exist
    3, // OP_ADD
    3, // OP_MULT
    1, // OP_INPUT
    1, // OP_OUTPUT
    2, // OP_JT
    2, // OP_JF
    3, // OP_LT
    3, // OP_EQ
    1, // OP_CHREL
};

class Machine {
    public:
        vector<m_t> m;
        int pc;
        int rel;
        queue<m_t> in;
        queue<m_t> out;

        Machine();
        void execute();
        bool running();
        void reserve(int);
};

Machine::Machine() {
    m = vector<m_t>();
    pc = 0;
    rel = 0;
    in = queue<m_t>();
    out = queue<m_t>();
}

void Machine::execute() {
    while (m[pc] != OP_HALT) {
        m_t instr = m[pc];
        m_t op = instr % 100;
        instr /= 100;
        m_t mode[num_params[op] + 1];
        m_t *param[num_params[op] + 1];
        param[0] = &op;

        for (int i = 1; i <= num_params[op]; i++) {
            mode[i] = instr % 10;
            switch(mode[i]) {
            case MODE_POS:
                assert(m[pc + i] >= 0);
                reserve(m[pc + i] + 1);
                param[i] = &m[m[pc + i]];
                break;
            case MODE_IMM:
                param[i] = &m[pc + i];
                break;
            case MODE_REL:
                assert(rel + m[pc + i] >= 0);
                reserve(rel + m[pc + i] + 1);
                param[i] = &m[rel + m[pc + i]];
                break;
            default:
                assert(false);
            }
            instr /= 10;
        }
        assert(instr == 0);

        switch (op) {
        case OP_ADD:
            assert(mode[3] != MODE_IMM);
            *param[3] = *param[1] + *param[2];
            pc += 4;
            break;
        case OP_MULT:
            assert(mode[3] != MODE_IMM);
            *param[3] = *param[1] * *param[2];
            pc += 4;
            break;
        case OP_INPUT:
            assert(mode[1] != MODE_IMM);
            if (in.empty()) return;
            *param[1] = in.front();
            in.pop();
            pc += 2;
            break;
        case OP_OUTPUT:
            out.push(*param[1]);
            pc += 2;
            break;
        case OP_JT:
            if (*param[1] != 0) {
                pc = *param[2];
            } else {
                pc += 3;
            }
            break;
        case OP_JF:
            if (*param[1] == 0) {
                pc = *param[2];
            } else {
                pc += 3;
            }
            break;
        case OP_LT:
            assert(mode[3] != MODE_IMM);
            if (*param[1] < *param[2]) {
                *param[3] = 1;
            } else {
                *param[3] = 0;
            }
            pc += 4;
            break;
        case OP_EQ:
            assert(mode[3] != MODE_IMM);
            if (*param[1] == *param[2]) {
                *param[3] = 1;
            } else {
                *param[3] = 0;
            }
            pc += 4;
            break;
        case OP_CHREL:
            rel += *param[1];
            pc += 2;
            break;
        default:
            assert(false);
        }
    }
}

bool Machine::running() {
    return m[pc] != OP_HALT;
}

void Machine::reserve(int size) {
    if (m.size() < size) {
        m.resize(size, 0);
    }
}

bool is_scaffold(char pixel) {
    return pixel == '#'
        || pixel == '^'
        || pixel == 'v'
        || pixel == '<'
        || pixel == '>';
}

pair<int, int> move(pair<int, int> p, int dir) {
    switch (dir) {
    case 0:
        return make_pair(p.first, p.second - 1);
    case 1:
        return make_pair(p.first + 1, p.second);
    case 2:
        return make_pair(p.first, p.second + 1);
    case 3:
        return make_pair(p.first - 1, p.second);
    default:
        assert(false);
    }
}

string segment_str(vector<char> path, int start, int len) {
    string str = "";
    int move = 0;
    for (int i = 0; i < len; i++) {
        char c = path[start + i];
        if (c == '1') {
            move++;
            continue;
        }

        if (move) {
            str += to_string(move);
            str += ',';
        }
        move = 0;
        str += c;

        if (i < len - 1) {
            str += ',';
        }
    }

    if (move) {
        str += to_string(move);
    }

    return str;
}

bool segment_path(
    vector<char> &path,
    int path_start,
    vector<pair<int, int>> &segments,
    vector<int> &use_segments
) {
    // Stop if we're at the main memory limit.
    if (use_segments.size() > 10) {
        return false;
    }

    // Try each segment as a prefix.
    for (int s_i = 0; s_i < segments.size(); s_i++) {
        int s_start = segments[s_i].first;
        int s_len = segments[s_i].second;

        assert(s_start + s_len <= path_start);
        if (path.size() - path_start < s_len) {
            continue;
        }
        bool matches = true;
        for (int i = 0; i < s_len; i++) {
            if (path[path_start + i] != path[s_start + i]) {
                matches = false;
                break;
            }
        }
        if (matches) {
            use_segments.push_back(s_i);

            // If the prefix covers the whole path, this is a solution.
            if (path_start + s_len == path.size()) {
                return true;
            }

            bool solution = segment_path(path, path_start + s_len, segments, use_segments);
            if (solution) {
                return true;
            }

            use_segments.pop_back();
        }
    }

    // Stop if we're at the segment limit.
    if (segments.size() >= 3) {
        return false;
    }

    // Try each path prefix as a new segment.
    int max_len = path.size() - path_start;
    for (int len = 1; len <= max_len; len++) {
        // Stop if we're at the segment memory limit.
        if (segment_str(path, path_start, len).size() > 20) {
            break;
        }

        segments.push_back(make_pair(path_start, len));
        use_segments.push_back(segments.size() - 1);
        bool solution = segment_path(path, path_start + len, segments, use_segments);
        if (solution) {
            return true;
        }
        segments.pop_back();
        use_segments.pop_back();
    }

    return false;
}

int main() {
    Machine m;
    m_t instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        m.m.push_back(instr);
    }
    m.m[0] = 2;
    m.execute();

    set<pair<int, int>> scaffold;
    pair<int, int> pos;
    int dir;
    int x = 0, y = 0;
    while (!m.out.empty()) {
        char pixel = m.out.front();
        m.out.pop();

        if (is_scaffold(pixel)) {
            scaffold.insert(make_pair(x, y));
        }

        switch (pixel) {
        case '^':
            pos = make_pair(x, y);
            dir = 0;
            break;
        case '>':
            pos = make_pair(x, y);
            dir = 1;
            break;
        case 'v':
            pos = make_pair(x, y);
            dir = 2;
            break;
        case '<':
            pos = make_pair(x, y);
            dir = 3;
            break;
        }

        if (pixel == '\n') {
            if (x == 0) {
                break;
            }
            y++;
            x = 0;
        } else {
            x++;
        }
    }

    vector<char> path;
    while (true) {
        pair<int, int> new_pos = move(pos, dir);
        while (scaffold.find(new_pos) != scaffold.end()) {
            path.push_back('1');
            pos = new_pos;
            new_pos = move(pos, dir);
        }

        if (scaffold.find(move(pos, (dir + 1) % 4)) != scaffold.end()) {
            path.push_back('R');
            dir = (dir + 1) % 4;
        } else if (scaffold.find(move(pos, (dir + 3) % 4)) != scaffold.end()) {
            path.push_back('L');
            dir = (dir + 3) % 4;
        } else {
            break;
        }
    }

    vector<pair<int, int>> segments;
    vector<int> use_segments;
    assert(segment_path(path, 0, segments, use_segments));

    assert(m.running());
    for (int i = 0; i < use_segments.size(); i++) {
        if (i > 0) {
            m.in.push(',');
        }
        m.in.push('A' + use_segments[i]);
    }
    m.in.push('\n');
    for (auto s : segments) {
        for (auto c : segment_str(path, s.first, s.second)) {
            m.in.push(c);
        }
        m.in.push('\n');
    }
    m.in.push('n');
    m.in.push('\n');

    while (m.running()) {
        m.execute();
    }
    while (!m.out.empty()) {
        int out = m.out.front();
        if (out > 127) {
            cout << out << endl;;
        }
        m.out.pop();
    }

    return 0;
}
