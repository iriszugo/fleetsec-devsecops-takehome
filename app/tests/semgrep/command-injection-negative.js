const { execFile } = require("child_process");

function runCommand(host) {
    execFile(
        "/bin/ping",
        ["-c", "1", host],
        {
            shell: false,
            timeout: 3000
        },
        (error, stdout) => {
            if (error) {
                return;
            }

            console.log(stdout);
        }
    );
}

runCommand("127.0.0.1");
