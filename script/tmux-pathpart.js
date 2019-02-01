#! /usr/bin/env node
// vim: filetype=javascript
const q = require('q');
const path = require('path');
const _ = require('lodash');
const execFile = q.denodeify(require('child_process').execFile);
const cexecFile = (...args) => execFile(...args)
    .catch(e => ['', '', e])
    .spread((stdout, stderr, error) => ({stdout, stderr, error}));

const sh = require('mvdan-sh');

const syntax = sh.syntax;

const parser = syntax.NewParser();

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

            return (windows.find(x => x.path == pwd) || {}).partial;
        });
};

const getCmd = (cmd) => {
    return q.resolve()
        .then(() => {
            const tree = parser.Parse(cmd, null);

            let stmt = tree.StmtList.Stmts[0];
            while(stmt.Cmd.$type.split('.*')[1] == 'BinaryCmd') {
                stmt = stmt.Cmd.X
            }

            const exe = _(stmt.Cmd.Args[0].Parts).map(x => x.Value).join('');
            let firstArg;
            try {
                firstArg = _(stmt.Cmd.Args[1].Parts).map(x => x.Value).join('')
            }
            catch(e) { }

            if(/^bash/gi.test(exe)) {
                return null;
            }

            if(/^vim/gi.test(exe)) {
                return '\u{270f}\u{fe0f}';
            }

            if(/^docker/gi.test(exe)) {
                return `\u{1f433}${firstArg}`;
            }

            if(/^yarn/gi.test(exe)) {
                return `\u{1f9f6}${firstArg}`;
            }

            if(exe.includes('build')) {
                return '\u{1f477}\u{200d}\u{2640}\u{fe0f}';
            }

            return exe;
        });
};

const compressPathName = (name) => {
    let match;
    const pathPieces = [];
    let re = /([a-z0-9]?(^|[\W\-_]+)[a-z0-9]|.$)/ig;
    while(match = re.exec(name)) {
        pathPieces.push(match[0]);
    }

    return pathPieces.join('');
};

// Wrap the entire program in a promise in case it barfs. We don't want to dump garbage on the terminal.
module.exports = (params) => {
    return q.resolve()
        .then(() => {
            let pwd = params.pwd;

            return q.all([
                gitFolderName(pwd),
                shortenPwd(pwd),
                getCmd(params.cmd),
            ]);
        })
        .spread((gitFolderName, shortPwd, cmd) => {
            let pieces = [];
            if(gitFolderName) {
                if( gitFolderName.length > 20 || (shortPwd && shortPwd != gitFolderName) || cmd ) {
                    pieces.push(compressPathName(gitFolderName));
                }
                else {
                    pieces.push(gitFolderName);
                } 
            }

            if(shortPwd != gitFolderName) {
                pieces.push(shortPwd);
            }

            const finalCmd = cmd ? ' #[bg=magenta]#[fg=black]' + cmd + '#[bg=default]#[fg=default]' : '';

            return pieces.filter(x => x).join(' - ') + finalCmd;
        })
        .catch(e => {
            return 'ERROR';
        });
};
