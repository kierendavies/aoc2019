const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.on('line', line => {
    let [start, end] = line.split("-").map(n => parseInt(n));

    let validCount = 0;
    for (let pwi = start; pwi <= end; pwi++) {
        let pw = pwi.toString();
        let hasDouble = false;
        let currentRunLength = 1;
        for (let i = 1; i < pw.length; i++) {
            if (pw[i] === pw[i-1]) {
                currentRunLength += 1;
            } else {
                if (currentRunLength === 2) {
                    hasDouble = true;
                }
                currentRunLength = 1;
            }
        }
        if (currentRunLength === 2) {
            hasDouble = true;
        }

        let nonDecreasing = true;
        for (let i = 0; i < pw.length - 1; i++) {
            if (pw[i] > pw[i+1]) {
                nonDecreasing = false;
            }
        }

        if (hasDouble && nonDecreasing) {
            validCount++;
        }
    }

    console.log(validCount);
});
