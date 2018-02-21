#! /usr/bin/env node
// vim: filetype=javascript

const q = require('q');
const exec = require('child_process').exec;
let windowId = process.argv[2];

console.log(windowId);
