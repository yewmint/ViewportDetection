/**
 * Configurations
 */

var gulp    = require('gulp');
var coffee = require('gulp-coffee');
var watch  = require('gulp-watch');
var gutil = require('gulp-util');

gulp.task('coffee', function() {
  gulp.src('src/*.coffee')
      .pipe(coffee())
      .on('error', function(err) {
          gutil.log('coffee error: ', err.message);
          this.end();
      })
      .pipe(gulp.dest('dist/'));
});

gulp.task('default', ['coffee']);

gulp.task('watch', function() {
    gulp.watch([ 'src/**'], ['default']);
});
