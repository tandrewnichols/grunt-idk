chalk = require('chalk')

describe 'idk', ->
  Given -> @inquirer =
    prompt: sinon.stub()
  Given -> @subject = require('proxyquire').noCallThru() '../tasks/idk',
    inquirer: @inquirer

  Given -> @fakePromise =
    then: sinon.stub()

  Given -> @grunt =
    registerTask: sinon.stub()
    log:
      write: sinon.stub()
    config:
      getRaw: sinon.stub()
    task:
      run: sinon.stub()

  context 'no options', ->
    context 'less than 20 tasks', ->
      Given -> @grunt.task._tasks =
        foo:
          info: 'Alias for "baz" task'
        bar:
          info: 'Do bar'
          multi: true
        baz:
          info: 'Do baz'
      Given -> @foo = chalk.gray('foo:') + ' Alias for "baz" task'
      Given -> @bar = chalk.gray('bar:') + ' Do bar'
      Given -> @baz = chalk.gray('baz:') + ' Do baz'
      Given -> @inquirer.prompt.withArgs([
        type: 'checkbox'
        message: 'Select task'
        name: 'tasks'
        choices: [@foo, @bar, @baz]
        pageSize: 3
      ]).returns @fakePromise
      Given -> @fakePromise.onCall(0).callsArgWith(0, { tasks: [@foo, @bar, @baz] })


    context 'more than 20 tasks', ->
      context 'and no LINES', ->

      context 'and LINES set', ->
        
    
  context 'with options', ->
    
