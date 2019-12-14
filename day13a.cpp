#include <cassert>
#include <iostream>
#include <map>
#include <queue>
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

int main() {
    Machine m;
    m_t instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        m.m.push_back(instr);
    }
    
    m.execute();
    assert(!m.running());

    map<pair<int, int>, int> display;
    while(!m.out.empty()) {
        int x = m.out.front();
        m.out.pop();
        int y = m.out.front();
        m.out.pop();
        int t = m.out.front();
        m.out.pop();

        display[make_pair(x, y)] = t;
    }

    int blocks = 0;
    for (auto tile : display) {
        if (tile.second == 2) {
            blocks++;
        }
    }
    cout << blocks << endl;

    return 0;
}
