require! {
  gulp
  nissin
  'nissin/fonts'
  'gulp-shell': \shell
}

gulp.task \images-sync, shell.task ['rsync --delete -av ~/Dropbox/dataviz/"Hackathon Climat/exports images web/" src/assets/images']
