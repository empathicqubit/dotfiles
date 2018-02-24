#! /usr/bin/env node
const q = require('q');
const colors = require('colors/safe');
const execFile = q.denodeify(require('child_process').execFile);
const cexecFile = (...args) => execFile(...args).catch((e) => ['', '', e]);

const execGit = (pwd, ...args) => execFile('git', args, {
        cwd: pwd
});
const cexecGit = (pwd, ...args) => cexecFile('git', args, {
    cwd: pwd
});

const fs = require('fs')
const readFile = q.denodeify(fs.readFile);
const creadFile = (...args) => readFile(...args).catch(() => '');
const stat = q.denodeify(fs.stat);
const cstat = (name) => stat(name).catch(() => false);

const style = {
    defaultForegroundColor: colors.reset,

    defaultBackgroundColor: colors.reset,

    beforeText: '[',
    beforeForegroundColor: colors.yellow,
    beforeBackgroundColor: colors.reset,

    delimText: ' |',
    delimForegroundColor: colors.yellow,
    delimBackgroundColor: colors.reset,

    afterText: ']',
    afterForegroundColor: colors.yellow,
    afterBackgroundColor: colors.reset,

    branchForegroundColor: colors.cyan,
    branchBackgroundColor: colors.reset,

    branchAheadForegroundColor: colors.green,
    branchAheadBackgroundColor: colors.reset,

    branchBehindForegroundColor: colors.red,
    branchBehindBackgroundColor: colors.reset,

    branchBehindAndAheadForegroundColor: colors.yellow,
    branchBehindAndAheadBackgroundColor: colors.reset,

    beforeIndexText: '',
    beforeIndexForegroundColor: colors.green,
    beforeIndexBackgroundColor: colors.reset,

    indexForegroundColor: colors.green,
    indexBackgroundColor: colors.reset,

    workingForegroundColor: colors.red,
    workingBackgroundColor: colors.reset,

    stashForegroundColor: colors.blue,
    stashBackgroundColor: colors.reset,
    stashText: '$',

    rebaseForegroundColor: colors.reset,
    rebaseBackgroundColor: colors.reset,
};

// these globals are updated by __posh_git_ps1_upstream_divergence
let poshBranchAheadBy = 0;
let poshBranchBehindBy = 0;

// Returns the location of the .git/ directory.
const poshGitdir = (dir) => {
    // Note: this function is duplicated in git-completion.bash
    // When updating it, make sure you update the other one to match.
    return cexecGit(dir, 'rev-parse', '--git-dir')
        .spread((stdout, stderr) => {
            return stdout.trim();
        });
}

const poshGetConfig = (pwd) => {
    let cfg = {
        enableFileStatus: null,
        showStatusWhenZero: null,
        showStashState: null,
        enableStatusSymbol: null,
        describeStyle: null,
        enableGitStatus: null,

        branchIdenticalStatusSymbol: '',
        branchAheadStatusSymbol: '',
        branchBehindStatusSymbol: '',
        branchBehindAndAheadStatusSymbol: '',
    };

    return cexecGit(pwd, 'config', '--includes', '-l')
        .spread((stdout, stderr) => {
            let lines = stdout.split(/[\r\n]+/g);
            lines.forEach(line => {
                let [name, val] = line.trim().split(/\s*=\s*/g);
                name = name.toLowerCase();
                switch(name) {
                    case 'bash.enablefilestatus':
                        cfg.enableFileStatus = val;
                        break;
                    case 'bash.showstatuswhenzero':
                        cfg.showStatusWhenZero = val;
                        break;
                    case 'bash.showstashstate':
                        cfg.showStashState = val;
                        break;
                    case 'bash.enablestatussymbol':
                        cfg.enableStatusSymbol = val;
                        break;
                    case 'bash.describestyle':
                        cfg.describeStyle = val;
                        break;
                    case 'bash.enablegitstatus':
                        cfg.enableGitStatus = val;
                        break;
                }
            });

            switch(cfg.enableFileStatus) {
                case "true":
                    cfg.enableFileStatus = true;
                    break;
                case "false":
                    cfg.enableFileStatus = false;
                    break;
                default:
                    cfg.enableFileStatus = true;
                    break;
            }

            switch(cfg.showStatusWhenZero) {
                case "true":
                    cfg.showStatusWhenZero = true;
                    break;
                case "false":
                    cfg.showStatusWhenZero = false;
                    break;
                default:
                    cfg.showStatusWhenZero = false;
                    break;
            }

            switch(cfg.showStashState) {
                case "true":
                    cfg.showStashState = true;
                    break;
                case "false":
                    cfg.showStashState = false;
                    break;
                default:
                    cfg.showStashState = true;
                    break;
            }

            switch(cfg.enableStatusSymbol) {
                case "true":
                    cfg.enableStatusSymbol = true;
                    break;
                case "false":
                    cfg.enableStatusSymbol = false;
                    break;
                default:
                    cfg.enableStatusSymbol = true;
                    break;
            }

            if(cfg.enableStatusSymbol) {
                cfg.branchIdenticalStatusSymbol = ' \u2261';
                cfg.branchAheadStatusSymbol = ' \u2191';
                cfg.branchBehindStatusSymbol = ' \u2193';
                cfg.branchBehindAndAheadStatusSymbol = ' \u2195';
            }

            return cfg;
        });
};

const poshGitStatus = (pwd) => {
    let stats = {
        indexAdded: 0,
        indexModified: 0,
        indexDeleted: 0,
        indexUnmerged: 0,
        filesAdded: 0,
        filesModified: 0,
        filesDeleted: 0,
        filesUnmerged: 0,

        indexCount: 0,
        workingCount: 0,
    };

    return cexecGit(pwd, 'status', '--porcelain')
        .spread((stdout, stderr) => {
            let files = stdout.trim().split(/[\r\n]+/g);
            files.forEach(file => {
                switch(file[0]) {
                    case 'A':
                        stats.indexAdded++;
                        break;
                    case 'M':
                        stats.indexModified++;
                        break;
                    case 'R':
                        stats.indexModified++;
                        break;
                    case 'C':
                        stats.indexModified++;
                        break;
                    case 'D':
                        stats.indexDeleted++;
                        break;
                    case 'U':
                        stats.indexUnmerged++
                        break;
                }
                switch(file[1]) {
                    case '?':
                        stats.filesAdded++;
                        break;
                    case 'A':
                        stats.filesAdded++;
                        break;
                    case 'M':
                        stats.filesModified++;
                        break;
                    case 'D':
                        stats.filesDeleted++;
                        break;
                    case 'U':
                        stats.filesUnmerged++;
                        break;
                }
            });

            stats.indexCount = stats.indexAdded + stats.indexModified + stats.indexDeleted + stats.indexUnmerged;
            stats.workingCount = stats.filesAdded + stats.filesModified + stats.filesDeleted + stats.filesUnmerged;

            return stats;
        });
}

const poshGitEcho = (params) => {
    let g;
    let merge;

    const expandRebaseString = (rebaseInfo) => {
        if(rebaseInfo.step && rebaseInfo.total) {
            rebaseInfo.rebase = `${rebaseInfo.rebase} ${rebaseInfo.step}/${rebaseInfo.total}`
        }

        return rebaseInfo;
    }

    const rebaseInfoPromise = (isRebaseMerge) => {
        let rebase;
        if(isRebaseMerge) {
            return q.all([
                creadFile(merge + "/head-name", 'utf8'),
                creadFile(merge + "/msgnum", 'utf8'),
                creadFile(merge + "/end", 'utf8'),
                cstat(merge + '/interactive'),
            ])
                .spread((hn, msg, end, interactive) => {
                    if(interactive) {
                        rebase = '|REBASE-i';
                    }
                    else {
                        rebase = '|REBASE-m';
                    }

                    return [expandRebaseString({
                        b: hn.trim(),
                        step: msg.trim(),
                        total: end.trim(),
                        rebase: rebase,
                    })];
                });
        }
        else {
            let applyPath = g + '/rebase-apply';

            return q.all([
                cstat(applyPath),
                cstat(g + '/MERGE_HEAD'),
                cstat(g + '/CHERRY_PICK_HEAD'),
                cstat(g + '/REVERT_HEAD'),
                cstat(g + '/BISECT_LOG'),
            ])
            .spread((apply, merge, cherry, revert, bisect) => {
                let step;
                let total;

                if(apply) {
                    return q.all([
                        creadFile(applyPath + '/next', 'utf8'),
                        creadFile(applyPath + '/last', 'utf8'),
                        cstat(applyPath + '/rebasing'),
                        cstat(applyPath + '/applying'),
                    ])
                    .spread((next, last, rebasing, applying) => {
                        step = next.trim();
                        total = last.trim();

                        if(rebasing) {
                            rebase = '|REBASE';
                        }
                        else if(applying) {
                            rebase = '|AM';
                        }
                        else {
                            rebase = '|AM/REBASE'
                        }

                        return expandRebaseString({
                            step: step,
                            total: total,
                            rebase: rebase,
                        });
                    });
                }
                else if(merge) {
                    rebase = '|MERGING';
                }
                else if(cherry) {
                    rebase = '|CHERRY-PICKING';
                }
                else if(revert) {
                    rebase = '|REVERTING';
                }
                else if(bisect) {
                    rebase = '|BISECTING';
                }

                return expandRebaseString({
                    step: step,
                    total: total,
                    rebase: rebase,
                });
            });
        }
    }

    const detachedHeadInfoPromise = (isRebaseMerge, pwd) => {
        let isDetached = false;
        if(isRebaseMerge) {
            return {};
        }

        let b;
        return execGit(pwd, 'symbolic-ref', 'HEAD')
            .catch(err => {
                isDetached = true;

                const describePromise = () => {
                    switch(config.describeStyle) {
                        case 'contains':
                            return execGit(pwd, 'describe', '--contains', 'HEAD');
                            break;
                        case 'branch':
                            return execGit(pwd, 'describe', '--contains', '--all', 'HEAD');
                            break;
                        case 'describe':
                            return execGit(pwd, 'describe', 'HEAD');
                            break;
                        case 'default':
                        default:
                            return execGit(pwd, 'describe', '--tags', '--exact-match', 'HEAD');
                            break;
                    }
                };

                return describePromise();
            })
            .spread((stdout, stderr) => {
                b = stdout.trim();
                return;
            })
            .catch(() => {
                return readFile(g + '/HEAD', 'utf8')
                    .then((file) => b = file.trim().slice(0, 7))
                    .catch(() => b = 'unknown');
            })
            .then(() => {
                isDetached &&( b = `(${b})`);

                return {
                    b: b,
                    isDetached: isDetached,
                };
            });
    };

    const whereAreWePromise = (config, pwd) => {
        let hasStash = false;
        let isBare = '';
        let b;
        return cexecGit(pwd, 'rev-parse', '--is-inside-git-dir', '--is-bare-repository', '--is-inside-work-tree')
            .spread((stdout, stderr) => {

                let multi = stdout.trim().split(/[\r\n]+/g);

                let insideGitDir = multi[0];
                let bareRepo = multi[1];
                let insideWorkTree = multi[2];

                if('true' == insideGitDir) {
                    if('true' == bareRepo) {
                        isBare = 'BARE:';
                    }
                    else {
                        b = 'GIT_DIR!';
                    }
                }
                else if('true' == insideWorkTree) {
                    let promises = [poshGitPs1UpstreamDivergence()];
                    if(config.showStashState) {
                        let promise = execGit(pwd, 'rev-parse', '--verify', 'refs/stash')
                            .then(() => hasStash = true)
                            .catch(() => {});

                        promises.push(promise);
                    }

                    return q.all(promises);
                }
            })
            .then(() => ({
                hasStash: hasStash,
                isBare: isBare,
                b: b,
            }));
    };

    let statusPromise = (config, pwd) => {
        if(!config.enableFileStatus) {
            return {};
        }

        return poshGitStatus(pwd);
    };

    let mainPromise = (config) => {
        return q.resolve()
            .then(() => {
                return poshGitdir(params.pwd);
            })
            .then(gd => {
                if(!gd) {
                    return;
                }

                g = gd;
                merge = g + '/rebase-merge';

                return cstat(merge);
            })
            .then((isRebaseMerge) => {
                // FIXME The b variable may encounter race conditions here
                return q.all([
                    rebaseInfoPromise(isRebaseMerge),
                    detachedHeadInfoPromise(isRebaseMerge, params.pwd),
                    whereAreWePromise(config, params.pwd),
                    statusPromise(config, params.pwd),
                ]);
            })
            .spread((rebaseInfo, detachedHeadInfo, whereAreWe, stats) => {
                let b = whereAreWe.b || detachedHeadInfo.b || rebaseInfo.b;

                // Assemble *everything*
                let gitString;
                let branchString = `${whereAreWe.isBare}${b.replace('refs/heads/', '')}`;

                // before-branch text
                gitString = style.beforeBackgroundColor(style.beforeForegroundColor(style.beforeText));

                // branch
                if(poshBranchBehindBy && poshBranchAheadBy) {
                    gitString += style.branchBehindAndAheadBackgroundColor(style.branchBehindAndAheadForegroundColor(branchString + config.branchBehindAndAheadStatusSymbol));
                }
                else if(poshBranchBehindBy) {
                    gitString += style.branchBehindBackgroundColor(style.branchBehindForegroundColor(branchString + config.branchBehindStatusSymbol));
                }
                else if(poshBranchAheadBy) {
                    gitString += style.branchAheadBackgroundColor(style.branchAheadForegroundColor(branchString + config.branchAheadStatusSymbol));
                }
                else {
                    gitString += style.branchBackgroundColor(style.branchForegroundColor(branchString + config.branchIdenticalStatusSymbol));
                }

                // index status
                if(config.enableFileStatus) {
                    if(stats.indexCount || config.showStatusWhenZero) {
                        gitString += style.indexBackgroundColor(style.indexForegroundColor(` +${stats.indexAdded} ~${stats.indexModified} -${stats.indexDeleted}`));
                    }

                    if(stats.indexUnmerged) {
                        gitString += ' ' + style.indexBackgroundColor(style.indexForegroundColor(`!${stats.indexUnmerged}`));
                    }

                    if(stats.indexCount && (stats.workingCount || config.showStatusWhenZero)) {
                        gitString += style.delimBackgroundColor(style.delimForegroundColor(style.delimText));
                    }

                    if(stats.workingCount || config.showStatusWhenZero) {
                        gitString += style.workingBackgroundColor(style.workingForegroundColor(` +${stats.filesAdded} ~${stats.filesModified} -${stats.filesDeleted}`));
                    }

                    if(stats.filesUnmerged) {
                        gitString += ' ' + style.workingBackgroundColor(style.workingForegroundColor(`!${stats.filesUnmerged}`));
                    }
                }

                if(rebaseInfo.rebase) {
                    gitString += style.rebaseBackgroundColor(style.rebaseForegroundColor(rebaseInfo.rebase));
                }

                // after-branch text
                gitString += style.afterBackgroundColor(style.afterForegroundColor(style.afterText));

                // stash
                if(config.showStashState && whereAreWe.hasStash) {
                    gitString += style.stashBackgroundColor(style.stashForegroundColor(style.stashText));
                }

                gitString += style.defaultBackgroundColor(style.defaultForegroundColor('\0'));

                return gitString;
            });
    };

    return poshGetConfig(params.pwd)
        .then(config => {
            if(config.enableGitStatus === 'false') {
                return;
            }

            return mainPromise(config);
        });
}

// Updates the global variables poshBranchAheadBy and poshBranchBehindBy.
const poshGitPs1UpstreamDivergence = (pwd) => {
    let svnRemote = [];
    let svnUrlPattern;
    let upstream='git';
    let legacy='';
    let showUpstream = [];

    return cexecGit(pwd, 'config', '-z', '--get-regexp', '^(svn-remote\\..*\\.url|bash\\.showUpstream)$')
        .spread((stdout, stderr) => {
            let cfgPairs = stdout.trim().split('\0');
            cfgPairs.forEach(pair => {
                let [key, value] = pair.split('\n');
                if(/^bash.showUpstream$/gi.test(key)) {
                    showUpstream=value.split(/\s+/g);
                    if(!showUpstream) {
                        return;
                    }
                }
                else if(/^svn-remote\..*\.url$/gi.test(key)) {
                    svnRemote.push(value);
                    svnUrlPattern+=`\\|${value}`;
                    upstream='svn+git';
                }
            });

            showUpstream.forEach(option => {
                switch(option) {
                    case 'git':
                    case 'svn':
                        upstream=option
                        break;
                    case 'legacy':
                        legacy=1
                        break;
                }
            });

            if(/^git$/gi.test(upstream)) {
                upstream='@{upstream}'
            }
            else if(/^svn.*$/gi.test(upstream)) {
                return cexecGit(pwd, 'log', '--first-parent', '-1', 
                    `--grep=^git-svn-id: ${svnUrlPattern.slice(-2)}`)
                    .spread((stdout, stderr) => {
                        let svnUpstream = stdout.trim().split(/[\s\r\n]+/g);

                        if(svnUpstream.length) {
                            svnUpstream = svnUpstream[svnUpstream.length - 2];
                            // TODO
                            svnUpstream = svnUpstream.replace(/^@+/g, '');

                            svnRemote.forEach(remote => {
                                svnUpstream = svnUpstream.replace(remote, '');
                            });

                            if(!svnUpstream) {
                                upstream = 'git-svn';
                            }
                            else {
                                upstream = svnUpstream.replace('/', '');
                            }
                        }
                        else if('svn+git' == upstream) {
                            upstream='@{upstream}';
                        }
                    });
            }
        })
        .then(() => {
            poshBranchAheadBy=0;
            poshBranchBehindBy=0;

            if(!legacy) {
                return cexecGit(pwd, 'rev-list', '--count', '--left-right', `${upstream}...HEAD`)
                    .spread((stdout, stderr) => {
                        let [poshBranchAheadBy, poshBranchBehindBy] = stdout.trim().split(/[\t\n ]+/g)
                    })
            }
            else {
                return cexecGit(pwd, 'rev-list', '--left-right', `${upstream}...HEAD`)
                    .spread((stdout, stderr) => {
                        let lines = stdout.trim().split(/[\r\n]+/g);
                        lines.forEach(line => {
                            let [commit] = line.split(/[\t\n ]+/g);
                            switch(commit) {
                                case '<*':
                                    poshBranchBehindBy++;
                                case '>*':
                                    poshBranchAheadBy++;
                            }
                        });
                    });
            }
        })
        .then(() => {
            poshBranchAheadBy || (poshBranchAheadBy = 0);
            poshBranchBehindBy || (poshBranchBehindBy = 0);
        });
}

poshGitEcho({
    pwd: process.cwd(),
})
    .then(str => console.log(str))
    .catch(console.error);
