#! /usr/bin/env node

const express = require('express');
const bodyParser = require('body-parser');
const tmuxPathpart = require('./tmux-pathpart');
const gitPrompt = require('./git-prompt');
const emojiWord = require('./emoji-word');
const getPort = require('get-port');

const main = async () => {
	if(process.argv[2] == '--find-port') {
		console.log(await getPort({ port: getPort.makeRange(29170, 30000) }));
		return;
	}

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
}

main().catch(console.error);
