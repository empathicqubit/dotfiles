#! /usr/bin/env node

const express = require('express');
const bodyParser = require('body-parser');
const tmuxPathpart = require('./tmux-pathpart');
const gitPrompt = require('./git-prompt');
const emojiWord = require('./emoji-word');

const app = express();

app.use(bodyParser.urlencoded({ extended: true }));

app.get('/tmux-pathpart', (req, res) => {
    tmuxPathpart(req.query)
        .then(r => res.send(r));
});

app.get('/git-prompt', (req, res) => {
    gitPrompt(req.query)
        .then(r => res.send(r));
});

app.get('/emoji-word', (req, res) => {
    emojiWord(req.query)
        .then(r => res.send(r));
});

app.listen(process.env.PROMPTUTIL_PORT, () => {});
