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
        Machine clone();
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

Machine Machine::clone() {
    Machine n;
    n.m = m;
    n.pc = pc;
    n.rel = rel;
    return n;
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

#define SQUARE_SIZE 100

bool probe(Machine &m, int x, int y) {
    Machine n = m.clone();
    n.in.push(x);
    n.in.push(y);
    n.execute();
    return n.out.front();
}

void fill_x_bounds(Machine &m, vector<pair<int, int>> &x_bounds, int y) {
    while (x_bounds.size() <= y) {
        int curr_y = x_bounds.size();

        if (curr_y < 50) {
            int x_l = 0, x_r = 0;
            int found_beam = false;
            for (int x = 0; x < 100; x++) {
                int probe_result = probe(m, x, curr_y);
                if (!found_beam && probe_result) {
                    x_l = x;
                    found_beam = true;
                } else if (found_beam && !probe_result) {
                    x_r = x;
                    break;
                }
            }
            x_bounds.push_back(make_pair(x_l, x_r));
            continue;
        }

        int last_y = curr_y - 1;

        int x_l = x_bounds[last_y].first;
        while (!probe(m, x_l, curr_y)) x_l++;

        int x_r = x_bounds[last_y].second;
        while (probe(m, x_r, curr_y)) x_r++;

        x_bounds.push_back(make_pair(x_l, x_r));
    }
}

bool square_fits(Machine &m, vector<pair<int, int>> &x_bounds, int y) {
    fill_x_bounds(m, x_bounds, y + SQUARE_SIZE - 1);
    int x_l = x_bounds[y + SQUARE_SIZE - 1].first;
    int x_r = x_bounds[y].second;
    return x_l + SQUARE_SIZE <= x_r;
}

int main() {
    Machine m;
    m_t instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        m.m.push_back(instr);
    }

    vector<pair<int, int>> x_bounds;
    int y_low = 0;
    int y_high = 1;
    while (!square_fits(m, x_bounds, y_high)) {
        y_low = y_high;
        y_high *= 2;
    }
    while (y_high - y_low > 1) {
        int y_mid = (y_low + y_high) / 2;
        if (square_fits(m, x_bounds, y_mid)) {
            y_high = y_mid;
        } else {
            y_low = y_mid;
        }
    }

    int y = y_low + 1;
    int x = x_bounds[y + SQUARE_SIZE - 1].first;

    cout << x * 10000 + y << endl;

    return 0;
}
