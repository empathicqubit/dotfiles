#! /usr/bin/env node

const tmuxPathpart = require('./tmux-pathpart');
const gitPrompt = require('./git-prompt');
const emojiWord = require('./emoji-word');
const readline = require('readline');

const commands = {
    tmuxPathpart,
    gitPrompt,
    emojiWord,
};

const main = async () => {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
        terminal: false,
    });

    rl.on('line', async (input) => {
        try {
            const data = JSON.parse(input);
            const result = await commands[data.command](data);
            console.log(result || '');
        }
        catch(e) {
            console.error(e);
            console.log('ERROR');
        }
    });
}

main().catch(console.error);
