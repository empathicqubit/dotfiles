#! /usr/bin/env node
// vim: filetype=javascript
const q = require('q');
const path = require('path');
const _ = require('lodash');
const execFile = q.denodeify(require('child_process').execFile);
const cexecFile = (...args) => execFile(...args)
    .catch(e => ['', '', e])
    .spread((stdout, stderr, error) => ({stdout, stderr, error}));

const cexecGit = (cwd, ...args) => execFile('git', args, {
    cwd: cwd,
}).catch((e) => ['', '', e]);

const gitFolderName = (pwd) => {
    return cexecGit(pwd, 'rev-parse', '--show-toplevel')
        .spread((stdout, stderr) => {
            return path.basename(stdout.trim());
        });
}

const systeminfo = [
    cexecFile('uname', ['-a']),
    cexecFile('reg.exe', ['Query', 'HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion', '/v', 'ReleaseId'])
];

const shortenPwd = (pwd) => {
    if(process.platform == 'win32') {
        return path.basename(pwd);
    }

    return q.all([
        ...systeminfo,
        cexecFile('tmux', ['list-windows', '-F', '["#{window_id}", "#{pane_current_path}"]'])
    ])
        .spread((uname, reg, tmux) => {
            if(uname.stdout.includes('Microsoft')) {
                try {
                    let buildNumber = parseInt(/^\s*ReleaseId\s+\w+\s+([0-9]+)\s*$/gm.exec(reg.stdout)[1]);
                    if(buildNumber < 1709) {
                        return path.basename(pwd);
                    }
                }
                catch(e) {
                    return e;
                    return path.basename(pwd);
                }
            }

            let current = null;
            let longest = 0;
            let windows = tmux.stdout.trim().split(/[\r\n]+/g).map(x => {
                let arr = JSON.parse(x);
                let parts = arr[1].split('/').filter(x => x);
                parts.reverse();
                if(longest < parts.length) {
                    longest = parts.length;
                }

                return {
                    id: arr[0],
                    path: arr[1],
                    parts: parts,
                };
            });

            let uniqueWindows = _.uniqBy(windows, 'path');

            for(let i = 0; i < longest; i++) {
                windows.forEach(win => {
                    let parts = win.parts.slice(0, i);
                    parts.reverse();
                    win.partial = parts.join('/');
                });

                if(_.uniqBy(windows, 'partial').length == uniqueWindows.length) {
                    break;
                }
            }

            return windows.find(x => x.path == pwd).partial;
        });
};

const getCmd = (cmd) => {
    return q.resolve()
        .then(() => {
            let parts = cmd.split(/\s+/g).filter(x => x != 'sudo');

            let exe = parts[0];

            if(exe == 'bash') {
                return '\u{1f41a}';
            }

            if(exe == 'vim') {
                return '\u{1f4dd}';
            }

            return exe;
        });
};

shortenPwd('/home/jessica/dotfiles')
    .then(x => console.error(x))
    .catch(e => console.error(e));

// Wrap the entire program in a promise in case it barfs. We don't want to dump garbage on the terminal.
module.exports = (params) => {
    return q.resolve()
        .then(() => {
            let pwd = params.pwd;

            q.which
            return q.all([
                gitFolderName(pwd),
                shortenPwd(pwd),
                getCmd(params.cmd),
            ]);
        })
        .spread((gitFolderName, shortPwd, cmd) => {
            let pieces = [];
            gitFolderName && pieces.push(gitFolderName);
            shortPwd != gitFolderName && pieces.push(shortPwd);
            return pieces.join(' - ') + ' (' + cmd + ')';
        })
        .catch(e => {
            return 'ERROR';
        });
};
