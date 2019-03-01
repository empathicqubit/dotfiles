#! /usr/bin/env node
const promisify = require('util').promisify;
const childProcess = require('child_process');
const execFile = promisify(childProcess.execFile);
const spawn = require('child_pty').spawn;

let pullStarted = false;
let pullEnded = false;

const oldTitlePromise = 
    execFile('tmux', ['display', '-pt', '?', '#{pane_title}'], {
        windowsHide: true,
    }).catch(() => ({ stdout: '', stderr: '' })); 

const whale = '\u{1f433}';

const setTitle = async (title) => {
    const oldTitle = await oldTitlePromise;
    const pre = oldTitle.stdout.split(whale)[0];
    let newTitle = oldTitle.stdout;
    if(title) {
        newTitle = pre + whale + title;
    }
    process.stdout.write('\x1b]2;' + newTitle + '\x1b\\');
};

const progress = {};
let lastHash = '';
let averageTotal = 0;
const handle = async (data) => {
    const strData = data.toString();

    process.stdout.write(strData.replace(/\r\n?/g, '\n'));

    if(pullStarted && pullEnded) {
        return;
    }

    for(const line of strData.split(/[\r\n]+/g)) {
        if(!pullStarted) { 
            if (!/^.*:\s*Pulling\s+from\s+\S+\s*$/i.test(line)) {
                continue;
            }

            pullStarted = true;

            setTitle('pull');

            continue;
        }
        else if(!pullEnded) { 
            if(/^\s*Status:\s+Downloaded\s+newer\s+image\s+for/i.test(line)) {
                pullEnded = true;

                setTitle('pulled');

                setTitle();
                
                break;
            }
        }

        let match;
        if(match = /([0-9a-f]+):/ig.exec(line)) {
            lastHash = match[1] || lastHash;
        }

        if(!lastHash) {
            continue;
        }

        if(match = /(Pull\s+complete|Already\s+exists|Pulling\s+fs\s+layer|Downloading\s+\[([=>\s]+)\]\s+([0-9\.]+)\w+\/([0-9\.]+)\w+)/ig.exec(line)) {
            const eventType = match[1];
            const bar = match[2];
            const unit = match[3];
            const total = match[4];

            if(eventType == 'Already exists' || eventType == 'Pull complete') {
                const oldHash = progress[lastHash] || {};
                progress[lastHash] = {
                    unit: oldHash.total,
                    total: oldHash.total,
                }
            }
            else if(eventType == 'Pulling fs layer') {
                progress[lastHash] = {
                    unit: 0,
                    total: averageTotal,
                }
            }
            else if(bar && unit && total) {
                progress[lastHash] = { 
                    unit: parseFloat(unit),
                    total: parseFloat(total),
                };
            }

            let units = 0; 
            let totals = 0;
            for(const p in progress) {
                const item = progress[p];
                units += item.unit;
                totals += item.total;
            }

            debugger;

            averageTotal = totals / Object.keys(progress).length;

            setTitle(((units / totals).toFixed(2) * 100) + '%');
        }
    }
};

let args = [...process.argv];
const debug = args.includes('--debug');

const main = async() => {
    args.shift();
    args.shift();

    if(debug) {
        args.shift();

        try {
            await execFile('docker', ['rmi', args[0]], {
                windowsHide: true,
            });
        }
        catch(e) {
            console.error(e);
            // Image already gone? 
        }

        args = ['run', '-it', '--rm', ...args];
    }

    const commandName = args.filter(x => x && !x.startsWith("-"));

    /* Output sample for pull
    alpine: Pulling from library/node
    6c40cc604d8e: Already exists
    bf8900ab0b62: Downloading [=>                                                 ]    440kB/21.57MB
    287f798ae2cd: Downloading [===============>                                   ]  423.6kB/1.332MB
    */

    const docker = spawn('docker', args, {
        columns: 200,
        rows: 1,
        name: 'xterm',
        cwd: process.cwd(),
    });

    !debug && process.stdin.setRawMode(true);
    process.stdin.pipe(docker.stdin);

    docker.stdout.on('data', data => handle(data).catch(e => debug && console.error(e)));

    docker.on('close', () => process.exit(0));
};

main()
    .then(() => {})
    .catch(e => {
        debug && console.error(e);
        process.exit(1);
    });
