#! /usr/bin/env node
const _ = require('lodash');
const util = require('util');
const execFile = util.promisify(require('child_process').execFile);

const getCommands = (input) => {
    const commands = [];

    const commandLines = input
        .split(/Commands:/gim)
        .pop()
        .split(/(\r\n|\r|\n){2}/gim)[0];

    const commandRegex = new RegExp('^\\s+(\\w+).*$', 'gim');

    let match;
    while(match = commandRegex.exec(commandLines)) {
        commands.push(match[1]);
    }

    return commands;
}

const getOptions = (input) => {
    const options = [];
    const optionLines = input
        .split(/Options:/gim)
        .pop()
        .split(/(\r\n|\r|\n){2}/gim)[0];

    const optionRegex = new RegExp('^\\s+(-+\\w+)?,?\\s*(-+\\w+)\\s+([a-z]+)?.*$', 'gm')

    while(match = optionRegex.exec(optionLines)) {
        options.push({
            short: match[1],
            long: match[2],
            type: match[3] || 'switch',
        });
    }

    return options;
}

const tryGetImage = (commands, options, cmd) => {
    cmd = cmd.split(' ');

    cmd.filter((arg, i) => {
        return !i && !commands.includes(arg) && (
            !arg.startsWith('-') || !options.find(option => args.startsWith('--') ? option.long == arg : )
        ))
    });
}

const main = async () => {
    const root = await execFile('docker', ['--help']);
    const rootRes = {
        commands: getCommands(root.stdout),
        options: getOptions(root.stdout),
    };

    const sub = await Promise.all(rootRes.commands.map(async x => {
        const ex = await execFile('docker', [x, '--help']);

        return getOptions(ex.stdout);
    }));

    const subOptions = _(sub).flatten().uniqBy('long').value();

    const allOptions = subOptions.concat(rootRes.options);

    console.log(tryGetImage(allOptions, 'docker run -it -v whatever:whatever -v stuff:stuff node:alpine this is some extra junk'));
};

main()
    .then(() => {
    })
    .catch(e => {
        console.error(e);
        process.exit(1);
    });
