var shell = require('./shellHelper');

var exec = require('child_process').exec;

// The browsers are configured to open multiple tabs as home-pages
var programs = [
  'chromium',          // open google mail & source control systems
  'firefox --browser', // open organizers like trello, swipes and my calendar; twitter
  'skype',             // it just doesn't start automatically on start-up
  'thunderbird',       // for personal mails & notifications
  'emacs'              // open the last saved desktop session
];

// execute multiple commands in series
shell.series(programs, function(err){
  console.log('All commands are executed');
});
