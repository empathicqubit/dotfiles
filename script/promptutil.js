#! /usr/bin/env node

const express = require('express');
const bodyParser = require('body-parser');
const tmuxPathpart = require('./tmux-pathpart');

const app = express();

app.use(bodyParser.urlencoded());

app.get('/tmux-pathpart', (req, res) => {
    tmuxPathpart(req.query)
        .then(r => res.send(r));
});

app.listen(process.env.PROMPTUTIL_PORT, () => {});
