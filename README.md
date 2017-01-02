[![Build Status](https://travis-ci.org/tandrewnichols/grunt-idk.png)](https://travis-ci.org/tandrewnichols/grunt-idk) [![downloads](http://img.shields.io/npm/dm/grunt-idk.svg)](https://npmjs.org/package/grunt-idk) [![npm](http://img.shields.io/npm/v/grunt-idk.svg)](https://npmjs.org/package/grunt-idk) [![Code Climate](https://codeclimate.com/github/tandrewnichols/grunt-idk/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/grunt-idk) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/grunt-idk/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/grunt-idk) [![dependencies](https://david-dm.org/tandrewnichols/grunt-idk.png)](https://david-dm.org/tandrewnichols/grunt-idk)

# grunt-idk

Interactive grunt help and task selection

![demo](idk.git)

## Getting Started

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```bash
npm install grunt-idk --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```javascript
grunt.loadNpmTasks('grunt-idk');
```

Alternatively, install [task-master](http://github.com/tandrewnichols/task-master) and let it manage this for you.

## The "idk" task

### Overview

Unlike most grunt plugins, you probably won't need to add a section to your config object for `idk`. `idk` is not a multi-task, and provides only two options (see below). So in many cases, you can just call `.loadNpmTasks` as defined above and be done.

The `idk` task provides an interactive prompt for selecting tasks and targets to run (because sometimes you just don't remember what you want to run). There are three stages to this:

First, you will be prompted to select tasks to run. Use `up` and `down` (or `j` and `k`) to navigate up and down and `spacebar` to select a task (or press `a` to select all or `i` to invert your current selection). When you've chosen your tasks, use `Enter` to confirm your selection.

Second, for each task you selected in the first prompt that is a multi-task, you will be prompted to select the targets for that task. Use the same controls as above to make your selections.

Finally, you will presented with your current selection and given a chance to reorder the tasks. In addition to the above controls use `left` or `h` to move a task _higher_ in the run queue or `right` or `l` to move it lower in the queue.

N.B. The second step will be skipped for multi-tasks with only one target, and the third step will be skipped if there is only one task to run.

By default, 20 items will be shown at one time in the prompt. You can configure this by setting `options.size` in your grunt config. If `options.size` (whether default or specified) is greater than the size of the terminal window (as specified by `process.env.LINES`), the size will be `process.env.LINES - options.offset` where `offset` defaults to 5.

Note that `LINES` and `COLUMNS` may or may not be available depending on your set up (and I have no idea how Windows handles such things). For me, by default, I can do `echo $LINES` and `echo $COLUMNS` and get correct numbers, but they are not available in child processes. So I have `export LINES=$LINES` and `export COLUMNS=$COLUMNS` in my bashrc. You can try this as well, or just always set `size` and `offset` to numbers sufficiently small enough. I have no idea if `inquirer` attempts to handle lists that would be off the screen or not.


### Example config

```js
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-idk');

  grunt.initConfig({
    idk: {
      options: {
        // 25 items showing (or however many will fit in the window)
        size: 25,
        // leave 3 line buffer if we hit the bottom of the terminal
        offset: 3
      }
    }
  });

  // You might want to register other aliases that you can remember, such as
  grunt.registerTask('help', ['idk']);
  // and/or
  grunt.registerTask('wtf', ['idk']);
  // and/or
  grunt.registerTask('prompt', ['idk']);
};
```

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
