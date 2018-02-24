#! /usr/bin/env node

const express = require('express');
const bodyParser = require('body-parser');
const tmuxPathpart = require('./tmux-pathpart');
const gitPrompt = require('./git-prompt');

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

app.listen(process.env.PROMPTUTIL_PORT, () => {});
