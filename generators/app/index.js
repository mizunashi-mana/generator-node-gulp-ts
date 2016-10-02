'use strict';
var yeoman = require('yeoman-generator');
var chalk = require('chalk');
var yosay = require('yosay');

module.exports = yeoman.Base.extend({
  prompting: function () {
    // Have Yeoman greet the user.
    this.log(yosay(
      'Welcome to the super-excellent ' + chalk.red('generator-node-gulp-ts') + ' generator!'
    ));

    var prompts = [];

    return this.prompt(prompts).then(function (props) {
      // To access props later use this.props.someAnswer;
      this.props = props;
    }.bind(this));
  },

  writing: function () {
    this.fs.copyTpl(
      this.templatePath('_package.json'),
      this.destinationPath('package.json'),
      {}
    );
    this.fs.copyTpl(
      this.templatePath('gulpfile.coffee'),
      this.destinationPath('gulpfile.coffee'),
      {}
    );
    this.fs.copyTpl(
      this.templatePath('tsconfig.json'),
      this.destinationPath('tsconfig.json'),
      {}
    );

    this.fs.copyTpl(
      this.templatePath('src/**'),
      this.destinationPath('src'),
      {}
    );
    this.fs.copyTpl(
      this.templatePath('test/**'),
      this.destinationPath('test'),
      {}
    );
  },

  install: function () {
    this.installDependencies();
  }
});
