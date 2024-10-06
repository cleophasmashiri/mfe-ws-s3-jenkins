import codeCoverage from '@cypress/code-coverage/use-browserify-istanbul';
// import codeCoverage from '@cypress/code-coverage/use-browserify-istanbul'
import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
      // Use the reporter
      // on('file:preprocessor', require('@cypress/code-coverage/use-browserify-istanbul'));
      // codeCoverage(on, config);
      // Optional: Add other event listeners or plugins here

      return config;
    },
    supportFile: './src/support/e2e.ts',
    // Specify reporter and reporter options
    reporter: '../../node_modules/mocha-junit-reporter',
    reporterOptions: {
      mochaFile: 'reports-e2e/junit/results.xml',
      toConsole: false,
    },
     specPattern: 'src/e2e/*.cy.{js,jsx,ts,tsx}'
    // Other Cypress configurations
  },
});