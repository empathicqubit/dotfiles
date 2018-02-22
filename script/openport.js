#! /usr/bin/env node
const openport = require('openport');

openport.find({ startingPort: 1024, endingPort: 60000 }, (err, port) => {
    if(err) {
        process.exit(1);
    }

    console.log(port);

    process.exit(0);
});
