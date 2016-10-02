gulp = require 'gulp'
$ = do require 'gulp-load-plugins'
$.remapIstanbul = require 'remap-istanbul/lib/gulpRemapIstanbul'

require 'ts-node/register'

del = require 'del'
merge = require 'merge2'
tslint = require 'tslint'
runSequence = require 'run-sequence'

argv = require 'yargs'
  .argv

tsProjects =
  src: $.typescript.createProject 'tsconfig.json',
    typescript: require 'typescript'
  test: $.typescript.createProject 'test/tsconfig.json',
    typescript: require 'typescript'

gulp.task 'lint:ts', ->
  gulp.src [
    'src/**/*.ts'
    'test/**/*.ts'
  ]
    .pipe $.tslint
      tslint: tslint
    .pipe $.tslint.report()

gulp.task 'lint', (cb) ->
  runSequence 'lint:ts'
    , cb

gulp.task 'test:ts', ->
  gulp.src [
    'test/spec/**/*.test.ts'
  ], { read: false }
    .pipe $.mocha
      reporter: process.env.MOCHA_REPORTER || 'nyan'

gulp.task 'test', (cb) ->
  runSequence 'test:ts'
    , cb

gulp.task 'build:ts', ->
  tsResult = gulp.src [
    'src/**/*.ts'
  ]
    .pipe $.sourcemaps.init()
    .pipe tsProjects['src'] $.typescript.reporter.defaultReporter()

  merge [
    tsResult.js
      .pipe $.sourcemaps.write()
    tsResult.dts
  ]
    .pipe gulp.dest 'dist'

gulp.task 'build', [
  'build:ts'
]

gulp.task 'coverage:ts', [
  'coverage:transts'
], ->
  gulp.src [
    'coverage/coverage-final.json'
  ]
    .pipe $.remapIstanbul
      reports:
        'text': undefined
        'text-summary': undefined
        'lcovonly': 'coverage/ts-lcov.info'
        'json': 'coverage/ts-coverage-final.json'
        'html': 'coverage/ts-lcov-report'
      reportOpts:
        log: console.log

gulp.task 'coverage', (cb) ->
  runSequence 'coverage:ts'
    , cb

gulp.task 'clean', (cb) ->
  del [
    'dist'
    'test-dist'
    'coverage'
  ], cb

gulp.task 'build:ts-test', [
  'build:ts'
], ->
  gulp.src [
    'test/**/*.ts'
  ]
    .pipe $.sourcemaps.init()
    .pipe tsProjects['test'] $.typescript.reporter.defaultReporter()
    .js
    .pipe $.sourcemaps.write()
    .pipe gulp.dest 'test-dist'

gulp.task 'coverage:ts-pre', [
  'build:test-ts'
], ->
  gulp.src [
    'dist/**/*.js'
  ]
    .pipe $.istanbul()
    .pipe $.istanbul.hookRequire()

gulp.task 'coverage:transts', [
  'coverage:ts-pre'
], ->
  gulp.src [
    'test-dist/spec/**/*.test.js'
  ], { read: false }
    .pipe $.mocha
      reporter: process.env.MOCHA_REPORTER || 'spec'
    .pipe $.istanbul.writeReports
      reporters: ['lcov', 'json']
