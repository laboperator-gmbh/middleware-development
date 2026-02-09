/* eslint-disable no-console */
const path = require('path');
const { execSync } = require('child_process');

const fse = require('fs-extra');

module.exports = async () => {
  try {
    console.log('Initializing middleware...');

    console.log('Copying boilerplate...');
    await fse.copy(path.resolve(__dirname, '../templates/init'), '.');

    console.log('Installing dependencies...');
    execSync(
      'yarn add middleware@laboperator-gmbh/middleware swagger-client@3.18.5',
      { stdio: 'inherit' },
    );
    execSync('yarn add --dev eslint@^9.39.2 prettier typescript', {
      stdio: 'inherit',
    });

    console.log("Done! Don't forget to update config.yml!");
  } catch (error) {
    console.error(error);
  }
};
