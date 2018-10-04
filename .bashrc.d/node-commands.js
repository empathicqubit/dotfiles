const shell = require('shelljs');
const fs = require('fs').promises;
const scriptName = process.argv[2]
const scripts = {
    add_debug: () => {
        shell.config.fatal = true;
        shell.exec('yarn add nodemon');
        const packagePath = process.cwd() + '/package.json';
        const package = require(packagePath);
        package.scripts = package.scripts || {};
        package.scripts.debug = 'nodemon -- --inspect-brk ./index.js';
        return Promise.resolve()
            .then(() => fs.writeFile(packagePath, JSON.stringify(package, null, 4), 'utf8'));
    }
};

scripts[scriptName]()
    .catch(e => {
        process.exit(1);
    });
