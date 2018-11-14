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

//        pstree -w $$ | grep -o '^[[:space:][:punct:]]\+[[:space:]][[:digit:]]\+[[:space:]]' | grep -o '[[:digit:]]\+' | xargs -I'{}' ps -p {} -o lstart=

const getCmd = (cmd, pid) => {
    return q.resolve()
        .then(() => {
            if(pid) {
                return q.resolve()
                    .then(() => cexecFile('pstree', ['-w', pid]))
                    .then((res) => {
                        let rex = /^\s*\W+\s+([0-9]+)\s+/gim ;
                        let pids = []; 
                        while(m = rex.exec(res.stdout)) pids.push(m[1]);

                        return q.all(cexecFile('ps', ['-p', pids.join(','), '-o', 'lstart=', '-o', 'comm=']))
                    })
                    .then(res => res.stdout.split(/\s*[\r\n]+\s*/g).sort().pop().split(/\s+/g).pop());
            }
            else {
                const tree = parser.Parse(cmd, null);

                let stmt = tree.StmtList.Stmts[0];
                while(stmt.Cmd.$type.split('.*')[1] == 'BinaryCmd') {
                    stmt = stmt.Cmd.X
                }

                const exe = stmt.Cmd.Args[0].Parts.map(x => x.Value).join('');

                return exe;
            }
        })
        .then((exe) => {
            exe = path.basename(exe);

            if(/^bash/gi.test(exe)) {
                return null;
            }

            if(/^vim/gi.test(exe)) {
                return '\u{270f}\u{fe0f}';
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
                getCmd(params.cmd, params.pid),
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
            console.error(e);
            return 'ERROR';
        });
};
