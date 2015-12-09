var shell = require('./shellHelper');

var exec = require('child_process').exec;

var programs = [
  'chromium',
  'firefox --browser',
  'skype',
  'thunderbird'
];

// execute multiple commands in series
shell.series(programs, function(err){
  console.log('All commands are executed');
});
