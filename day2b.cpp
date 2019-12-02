#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main() {
    vector<int> mm;
    int instr;
    while (cin >> instr) {
        cin.ignore(1, ',');
        mm.push_back(instr);
    }

    for (int noun = 0; noun < 100; noun++) {
        for (int verb = 0; verb < 100; verb++) {
            vector<int> m = mm;
            m[1] = noun;
            m[2] = verb;

            int pc = 0;
            while (m[pc] != 99) {
                if (m[pc] == 1) {
                    m[m[pc+3]] = m[m[pc+1]] + m[m[pc+2]];
                } else if (m[pc] == 2) {
                    m[m[pc+3]] = m[m[pc+1]] * m[m[pc+2]];
                }
                pc += 4;
            }

            if (m[0] == 19690720) {
                cout << 100 * noun + verb << endl;
                return 0;
            }
        }
    }

    return 1;
}
