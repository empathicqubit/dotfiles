#! /usr/bin/env node
// vim: filetype=javascript
const q = require('q');
const _ = require('lodash');
const execFile = q.denodeify(require('child_process').execFile);

// Wrap the entire program in a promise in case it barfs. We don't want to dump garbage on the terminal.
module.exports = (params) => {
    return Promise.resolve()
        .then(() => {
            let pwd = params.pwd;
            let cmd = params.cmd || '';

            const skipTmux = () => {
                return pwd + ' ' + cmd.trim().split(' ')[0];
            }

            if(process.platform == 'win32') {
                return skipTmux();
            }

            return execFile('uname', ['-a'])
                .spread((stdout, stderr) => {
                    if(stdout.includes('Microsoft')) {
                        return skipTmux();
                    }

                    return execFile('tmux', ['list-windows', '-F', '["#{window_id}", "#{pane_current_path}"]'])
                        .spread((stdout, stderr) => {
                            let current = null;
                            let longest = 0;
                            let windows = stdout.trim().split(/[\r\n]+/g).map(x => {
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

                            return windows.find(x => x.path == pwd).partial + ' ' + cmd.trim().split(' ')[0];
                        });
                })
        })
        .catch(e => {
            return 'ERROR';
        });
};
