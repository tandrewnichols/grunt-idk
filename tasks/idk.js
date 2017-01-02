const inquirer = require('inquirer');
inquirer.registerPrompt('ordered', require('inquirer-orderedcheckbox'));
const _ = require('lodash');
const chalk = require('chalk');
const strip = require('strip-ansi');
const async = require('async');
const DEFAULT_PAGE_SIZE = 20;
const DEFAULT_PAGE_OFFSET = 5;

module.exports = function(grunt) {
  grunt.registerTask('idk', require('../package').description, function() {
    // Tell grunt to wait for the task to complete
    var done = this.async();
    grunt.log.write('\033[0;0H\033[2J');
    var options = this.options({
      size: DEFAULT_PAGE_SIZE,
      offset: DEFAULT_PAGE_OFFSET
    });

    // Make tasks an array
    var tasks = _.chain(grunt.task._tasks).reduce((memo, val, task) => {
      val.choice = `${chalk.gray(task)}${chalk.gray(':')} ${val.info}`;
      memo.push(val);
      return memo;
    }, []).sortBy('name').value();

    var calcSize = list => {
      var pageSize = list.length > options.size ? options.size : list.length;
      if (process.env.LINES && pageSize > process.env.LINES) {
        pageSize = process.env.LINES - options.offset;
      }
      return pageSize;
    };

    inquirer.prompt([{
      type: 'checkbox',
      message: 'Select task',
      name: 'tasks',
      choices: _.map(tasks, 'choice'),
      pageSize: calcSize(tasks)
    }]).then(answers => {
      answers = _.map(answers.tasks, task => strip(task).split(':')[0]);
      async.mapSeries(answers, function(answer, next) {
        var task = _.find(tasks, { name: answer });
        if (task.multi) {
          var config = grunt.config.getRaw(task.name);
          var targets = _(config).omit(['options']).keys().map(target => `${task.name}:${target}`).value();
          inquirer.prompt([{
            type: 'checkbox',
            message: 'Select target(s)',
            name: 'targets',
            choices: targets,
            pageSize: calcSize(targets)
          }]).then(answers => {
            // If they select all, don't pass a target at all
            if (answers.targets.length === targets.length) {
              next(null, answer);
            } else {
              next(null, answers.targets);
            }
          });
        } else {
          next(null, answer);
        }
      }, function(err, tasksToRun) {
        if (err) {
          done(err);
        }
        tasksToRun = _.flatten(tasksToRun);
        inquirer.prompt([{
          type: 'ordered',
          message: 'Use h to move a task higher, l to move it lower',
          name: 'order',
          choices: tasksToRun,
          default: tasksToRun,
          pageSize: calcSize(tasksToRun)
        }]).then(answers => {
          grunt.task.run(answers.order);
          done();
        });
      });
    });
  });
};
