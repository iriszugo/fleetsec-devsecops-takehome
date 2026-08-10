const { exec } = require("child_process");

function runCommand(userInput) {
    const command = `ping -c 1 ${userInput}`;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(stderr);
            return;
        }

        console.log(stdout);
    });
}

runCommand(process.argv[2]);
