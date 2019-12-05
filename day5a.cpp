#include <cassert>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

#define OP_ADD 1
#define OP_MULT 2
#define OP_INPUT 3
#define OP_OUTPUT 4

#define MODE_POS 0
#define MODE_IMM 1

const int num_params[] = {
    0, // does not exist
    3, // OP_ADD
    3, // OP_MULT
    1, // OP_INPUT
    1, // OP_OUTPUT
};

void execute(vector<int> &m) {
    int pc = 0;
    while (m[pc] != 99) {
        int instr = m[pc];
        int op = instr % 100;
        instr /= 100;
        int mode[num_params[op] + 1];
        int param[num_params[op] + 1];
        param[0] = op;

        for (int i = 1; i <= num_params[op]; i++) {
            mode[i] = instr % 10;
            switch(mode[i]) {
            case MODE_POS:
                param[i] = m[m[pc + i]];
                break;
            case MODE_IMM:
                param[i] = m[pc + i];
                break;
            default:
                assert(false);
            }
            instr /= 10;
        }
        assert(instr == 0);

        switch (op) {
        case OP_ADD:
            assert(mode[3] == MODE_POS);
            m[m[pc+3]] = param[1] + param[2];
            break;
        case OP_MULT:
            assert(mode[3] == MODE_POS);
            m[m[pc+3]] = param[1] * param[2];
            break;
        case OP_INPUT:
            assert(mode[1] == MODE_POS);
            m[m[pc+1]] = 1;
            break;
        case OP_OUTPUT:
            cout << param[1] << endl;
            break;
        default:
            assert(false);
        }

        pc += 1 + num_params[op];
    }
}

int main() {
    vector<int> m;
    int instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        m.push_back(instr);
    }

    execute(m);

    return 0;
}
