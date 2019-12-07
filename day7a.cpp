
#include <algorithm>
#include <cassert>
#include <iostream>
#include <queue>
#include <string>
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

#define MODE_POS 0
#define MODE_IMM 1

#define NUM_AMPS 5

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
};

int execute(vector<int> &m, queue<int> &inputs) {
    int last_output = -1;
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
            pc += 4;
            break;
        case OP_MULT:
            assert(mode[3] == MODE_POS);
            m[m[pc+3]] = param[1] * param[2];
            pc += 4;
            break;
        case OP_INPUT:
            assert(mode[1] == MODE_POS);
            m[m[pc+1]] = inputs.front();
            inputs.pop();
            pc += 2;
            break;
        case OP_OUTPUT:
            last_output = param[1];
            pc += 2;
            break;
        case OP_JT:
            if (param[1] != 0) {
                pc = param[2];
            } else {
                pc += 3;
            }
            break;
        case OP_JF:
            if (param[1] == 0) {
                pc = param[2];
            } else {
                pc += 3;
            }
            break;
        case OP_LT:
            if (param[1] < param[2]) {
                m[m[pc+3]] = 1;
            } else {
                m[m[pc+3]] = 0;
            }
            pc += 4;
            break;
        case OP_EQ:
            if (param[1] == param[2]) {
                m[m[pc+3]] = 1;
            } else {
                m[m[pc+3]] = 0;
            }
            pc += 4;
            break;
        default:
            assert(false);
        }
    }

    return last_output;
}

int main() {
    vector<int> m;
    int instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        m.push_back(instr);
    }

    int maxval = INT32_MIN;
    int phase[NUM_AMPS] = {};
    for (int i = 0; i < NUM_AMPS; i++) phase[i] = i;
    do {
        int val = 0;
        for (int i = 0; i < NUM_AMPS; i++) {
            vector<int> mm = m;
            queue<int> inputs;
            inputs.push(phase[i]);
            inputs.push(val);
            val = execute(mm, inputs);
        }
        if (val > maxval) maxval = val;
    } while (next_permutation(phase, phase+5));
    cout << maxval << endl;

    return 0;
}
