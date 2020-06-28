const
  gulp = require('gulp'),
  connect = require('gulp-connect'),
  exec = require('child_process').exec;


gulp.task('serve', function () {
  connect.server({
    root: 'dist',
    host: '0.0.0.0',
    port: 8080,
    livereload: true
  });
});

gulp.task('hakyll', function(cb) {
  exec('stack exec site build', function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
    gulp.src('./dist').pipe(connect.reload());
    cb(err);
  })
});

gulp.task('clean', function (cb) {
  exec('stack exec site clean', function (err, stdout, stderr) {
    console.log(stdout);
    console.log(stderr);
    cb(err);
  })
});

gulp.task('build', gulp.series('hakyll'));

gulp.task('watch', function () {
  gulp.watch(['./src/**/*'], gulp.task('build'));
});

gulp.task('default', gulp.series('build', gulp.parallel('serve', 'watch')));
