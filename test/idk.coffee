chalk = require('chalk')
sinon = require('sinon')
async = require('async')

describe 'idk', ->
  Given -> @inquirer =
    prompt: sinon.stub()
    registerPrompt: sinon.stub()

  Given -> @subject = require('proxyquire').noCallThru() '../tasks/idk',
    inquirer: @inquirer
    '../package':
      description: 'Do some stuff'

  Given -> @grunt =
    registerTask: sinon.stub()
    log:
      write: sinon.stub()
    config:
      getRaw: sinon.stub()
    task:
      run: sinon.stub()
  Given -> @context =
    async: sinon.stub()
    options: sinon.stub()
  Given -> @grunt.registerTask.withArgs('idk', 'Do some stuff', sinon.match.func).callsArgOn(2, @context)

  Given -> @grunt.task._tasks =
    foo:
      name: 'foo'
      info: 'Alias for "baz" task'
    bar:
      name: 'bar'
      info: 'Do bar'
      multi: true
    baz:
      name: 'baz'
      info: 'Do baz'
  Given -> @foo = chalk.gray('foo') + chalk.gray(':') + ' Alias for "baz" task'
  Given -> @bar = chalk.gray('bar') + chalk.gray(':') + ' Do bar'
  Given -> @baz = chalk.gray('baz') + chalk.gray(':') + ' Do baz'
  Given -> @grunt.config.getRaw.withArgs('bar').returns { options: 1, quux: 2, blah: 3 }

  context 'no options', ->
    Given -> @context.options.returnsArg(0)
    # At the first inquirer prompt, select all tasks (foo, bar, baz)
    Given -> @inquirer.prompt.withArgs([
      type: 'checkbox'
      message: 'Select task'
      name: 'tasks'
      choices: [@bar, @baz, @foo]
      pageSize: 3
    ]).returns Promise.resolve({ tasks: [@bar, @baz, @foo] })
    # The second prompt will only happen for bar, as it's the only
    # multi task. Select only bar:quux.
    Given -> @inquirer.prompt.withArgs([
      type: 'checkbox'
      message: 'Select target(s)'
      name: 'targets'
      choices: ['bar:quux', 'bar:blah']
      pageSize: 2
    ]).returns Promise.resolve({ targets: ['bar:quux'] })
    # At the last prompt, reorder the items.
    Given -> @inquirer.prompt.withArgs([
      type: 'ordered'
      message: 'Use h to move a task higher, l to move it lower'
      name: 'order'
      choices: ['bar:quux', 'baz', 'foo']
      default: ['bar:quux', 'baz', 'foo']
      pageSize: 3
    ]).returns Promise.resolve({ order: ['baz', 'bar:quux', 'foo'] })
    When (done) ->
      @context.async.returns done
      @subject(@grunt)
    Then -> @grunt.task.run.should.have.been.calledWith ['baz', 'bar:quux', 'foo']
    
  context 'with options', ->
    context 'where options.size is smaller than the list length', ->
      Given -> @context.options.returns
        size: 2
        offset: 1

      # At the first inquirer prompt, select all tasks (foo, bar, baz)
      Given -> @inquirer.prompt.withArgs([
        type: 'checkbox'
        message: 'Select task'
        name: 'tasks'
        choices: [@bar, @baz, @foo]
        pageSize: 2
      ]).returns Promise.resolve({ tasks: [@bar, @baz, @foo] })
      # The second prompt will only happen for bar, as it's the only
      # multi task. Select all options.
      Given -> @inquirer.prompt.withArgs([
        type: 'checkbox'
        message: 'Select target(s)'
        name: 'targets'
        choices: ['bar:quux', 'bar:blah']
        pageSize: 2
      ]).returns Promise.resolve({ targets: ['bar:quux', 'bar:blah'] })
      # At the last prompt, reorder the items.
      Given -> @inquirer.prompt.withArgs([
        type: 'ordered'
        message: 'Use h to move a task higher, l to move it lower'
        name: 'order'
        choices: ['bar', 'baz', 'foo']
        default: ['bar', 'baz', 'foo']
        pageSize: 2
      ]).returns Promise.resolve({ order: ['baz', 'bar', 'foo'] })
      When (done) ->
        @context.async.returns done
        @subject(@grunt)
      Then -> @grunt.task.run.should.have.been.calledWith ['baz', 'bar', 'foo']

    context 'where process.env.LINES is smaller than the list length', ->
      Given -> @context.options.returns
        size: 10
        offset: 1
      Given -> process.env.LINES = 2
      # At the first inquirer prompt, select all tasks (foo, bar, baz)
      Given -> @inquirer.prompt.withArgs([
        type: 'checkbox'
        message: 'Select task'
        name: 'tasks'
        choices: [@bar, @baz, @foo]
        pageSize: 1
      ]).returns Promise.resolve({ tasks: [@bar, @baz, @foo] })
      # The second prompt will only happen for bar, as it's the only
      # multi task. Select all options.
      Given -> @inquirer.prompt.withArgs([
        type: 'checkbox'
        message: 'Select target(s)'
        name: 'targets'
        choices: ['bar:quux', 'bar:blah']
        pageSize: 2
      ]).returns Promise.resolve({ targets: ['bar:quux', 'bar:blah'] })
      # At the last prompt, reorder the items.
      Given -> @inquirer.prompt.withArgs([
        type: 'ordered'
        message: 'Use h to move a task higher, l to move it lower'
        name: 'order'
        choices: ['bar', 'baz', 'foo']
        default: ['bar', 'baz', 'foo']
        pageSize: 1
      ]).returns Promise.resolve({ order: ['baz', 'bar', 'foo'] })
      When (done) ->
        @context.async.returns done
        @subject(@grunt)
      Then -> @grunt.task.run.should.have.been.calledWith ['baz', 'bar', 'foo']

  context 'an error occurs', ->
    Given -> sinon.stub(async, 'mapSeries')
    afterEach -> async.mapSeries.restore()
    Given -> @context.options.returns
      size: 10
      offset: 1
    # At the first inquirer prompt, select all tasks (foo, bar, baz)
    Given -> @inquirer.prompt.withArgs([
      type: 'checkbox'
      message: 'Select task'
      name: 'tasks'
      choices: [@bar, @baz, @foo]
      pageSize: 1
    ]).returns Promise.resolve({ tasks: [@bar, @baz, @foo] })
    # But stub async.mapSeries so it passes an error
    Given -> async.mapSeries.withArgs(['bar', 'baz', 'foo'], sinon.match.func, sinon.match.func).callsArgWith(2, 'error')
    When (done) ->
      @context.async.returns (@err) => done()
      @subject(@grunt)
    Then -> @err.should.equal 'error'
