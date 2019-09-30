---
title: "AngularJS - Minify resources and Cache Busting"
date: 2019-04-30T23:05:44+02:00
draft: false
---

# Single page aplication

When dealing with Single page application (SPA), it is nessesary to think about minifying those js and css files, and combining those in single files, to speed up loading of app.

Also there is another issue with caching. When You release new version, browser won't load new files, until You go into developer tools, and disable caching. But this is not a solution for production app.

Here comes in play "Cache Busting".

# Example project

I created example AngularJS project, where is used [Gulp](https://gulpjs.com/) to minify and do Cache Busting for release version of site in public folder

[AngularJS - Minify resources and Cache Busting example](https://github.com/dkeza/angularjs-templates-example)

Project has three partials as html files in templates directory. In app.js file is created angular app and controllers, which are using those partials.
In css directory are css files, and in js directory are Javascript files.

You can folow steps how I created this project.

* AngularJS project, without minifying files [81a514d2b3ccff852d5c5b367b2c832ab0ae6b91](https://github.com/dkeza/angularjs-templates-example/tree/81a514d2b3ccff852d5c5b367b2c832ab0ae6b91)
* Added code to minify files and copy release files to public directory. Web site root is now in public directory. [e054a1e2789aa786d169640981555c69bfaedbe4](https://github.com/dkeza/angularjs-templates-example/tree/e054a1e2789aa786d169640981555c69bfaedbe4)
* Added code to also add Cache Bursting [fef9f5b46340e67517a616c616e1c7ff3dab02d0](https://github.com/dkeza/angularjs-templates-example/tree/fef9f5b46340e67517a616c616e1c7ff3dab02d0)

# Install dependencies

For minifying and Cache Busting I will use [Gulp](https://gulpjs.com/) tool.

I will assume you have already installed [Node](https://nodejs.org/en/) with npm on your machine.

# Install Gulp

Installing Gulp CLI

{{< highlight bash >}}
npm install --global gulp-cli
{{< /highlight >}}

Now CD into your AngularJS project root, and initialize Node dependency file with

{{< highlight bash >}}
npm init
{{< /highlight >}}

Answer all questions with defaults.
Now you have created package.json file, where npm stores reference which dependency are used in your project.

Install Gulp modules needed

{{< highlight bash >}}
npm install --save-dev gulp gulp-if gulp-useref gulp-uglify gulp-clean-css del gulp-cache-bust gulp-string-replace
{{< /highlight >}}

Create file gulpfile.js and paste this code:

{{< highlight javascript >}}

var gulp  = require('gulp');
var gulpif = require('gulp-if');
var useref = require('gulp-useref');
var uglify = require('gulp-uglify');
var minifyCss = require('gulp-clean-css');
var del = require('del');
var cachebust = require('gulp-cache-bust');
var replace = require('gulp-string-replace');
var versionTimeStamp = "" + Date.now();

gulp.task('delete_all', function() {
  return del([
    'public/*.*',
    'public/css/*.*',
    'public/images/*.*',
    'public/js/*.*',
    'public/templates/*.*'
  ]);
});

gulp.task('minify', function(){
  return gulp.src('index.html')
          .pipe(useref())
          .pipe(replace('___REPLACE_IN_GULP___', versionTimeStamp))
          .pipe(gulpif('*.js', uglify()))
          .pipe(gulpif('*.css', minifyCss()))
          .pipe(cachebust({
            type: 'timestamp'
          }))
          .pipe(gulp.dest('public'));
});

gulp.task('copy1', function () {
    return gulp.src('templates/*.*')
        .pipe(gulp.dest('public/templates'));
});

gulp.task('copy2', function () {
  return gulp.src('images/*.*')
      .pipe(gulp.dest('public/images'));
});

gulp.task('default', gulp.series('delete_all', 'minify', 'copy1', 'copy2'));

{{< /highlight >}}

# Changes to project source

Before running Gulp script, we must do some changes in source.

We want to minify javascript and css files and combine those into just one file (one for js and one for css).

This is done adding comments to index.html

{{< highlight html >}}
<!DOCTYPE html>

<html lang="en">

<head>
  <meta charset="utf-8">
  <title>AngularJS template example</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="//fonts.googleapis.com/css?family=Raleway:400,300,600" rel="stylesheet" type="text/css">
  <!-- build:css modules/css/release.css -->
  <link rel="stylesheet" href="css/normalize.css">
  <link rel="stylesheet" href="css/skeleton.css">
  <link rel="stylesheet" href="css/main.css">
  <!-- endbuild -->
  <link rel="icon" type="image/png" href="images/favicon.png">
</head>

<body>

  <div ng-app="App" class="container">
    <div class="row">
      <div class="one-half column" style="margin-top: 25%">
        <h2>AngularJS template example</h2>
        <div id="nav" class="fourteen columns">
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/#!page1">Page 1</a></li>
            <li><a href="/#!page2">Page 2</a></li>
          </ul>
        </div>
        <div ng-controller="homeController">
          <div ng-view></div>
        </div>
      </div>
    </div>
  </div>

  <!-- build:js modules/js/release.js -->
  <script src="js/angular.min.js"></script>
  <script src="js/angular-route.min.js"></script>
  <script src="js/app.js"></script>
  <!-- endbuild -->

</body>

</html>
{{< /highlight >}}

Here are important those line

{{< highlight html >}}
<!-- build:css modules/css/release.css -->


<!-- endbuild -->
{{< /highlight >}}

and

{{< highlight html >}}
<!-- build:js modules/js/release.js -->


<!-- endbuild -->
{{< /highlight >}}

Everything between those lines will be combined in just one file, release.css and release.js. Links would be fixed in index.html by Gulp.

We must also add some code to AngularJS part, to intercept every request to our templates directory, where our html partials are stored, and to add query with time stamp at the end of url.

I have added this to my app.js file:

{{< highlight javascript >}}
  app.service('preventTemplateCache', [function() {
    var service = this;
    service.request = function(config) {
      if (config.url.indexOf('templates') !== -1) {
        config.url = config.url + '?t=___REPLACE_IN_GULP___'
      }
      return config;
    };
  }]);

  app.config(['$httpProvider',function ($httpProvider) {
    $httpProvider.interceptors.push('preventTemplateCache');
  }]);
{{< /highlight >}}

Place holder ```___REPLACE_IN_GULP___``` would be changed with time stamp in gulpfile.js

{{< highlight javascript >}}
gulp.task('minify', function(){
  return gulp.src('index.html')
          .pipe(useref())
          .pipe(replace('___REPLACE_IN_GULP___', versionTimeStamp))
          .pipe(gulpif('*.js', uglify()))
          .pipe(gulpif('*.css', minifyCss()))
          .pipe(cachebust({
            type: 'timestamp'
          }))
          .pipe(gulp.dest('public'));
});
{{< /highlight >}}

# Create release version of web site

Now we can call gulp-cli command

{{< highlight bash >}}
gulp
{{< /highlight >}}

and see log of executed commands

{{< highlight bash >}}
[09:15:59] Using gulpfile ~\code\source\web\angularjs-templates-example\gulpfile.js
[09:15:59] Starting 'default'...
[09:15:59] Starting 'delete_all'...
[09:15:59] Finished 'delete_all' after 53 ms
[09:15:59] Starting 'minify'...
[09:16:00] Replaced: "___REPLACE_IN_GULP___" to "1556694959784" in a file: ~\code\source\web\angularjs-templates-example\modules\js\release.js
[09:16:04] Finished 'minify' after 4.95 s
[09:16:04] Starting 'copy1'...
[09:16:04] Finished 'copy1' after 17 ms
[09:16:04] Starting 'copy2'...
[09:16:04] Finished 'copy2' after 7.8 ms
[09:16:04] Finished 'default' after 5.05 s
{{< /highlight >}}

Take a look into generated source in public folder. You will see in index.html, that we have only one js and css file, with time stamp added as query parameter

{{< highlight html >}}
<!DOCTYPE html>

<html lang="en">

<head>
  <meta charset="utf-8">
  <title>AngularJS template example</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="//fonts.googleapis.com/css?family=Raleway:400,300,600" rel="stylesheet" type="text/css">
  <link rel="stylesheet" href="modules/css/release.css?t=1556694960179">
  <link rel="icon" type="image/png" href="images/favicon.png">
</head>

<body>

  <div ng-app="App" class="container">
    <div class="row">
      <div class="one-half column" style="margin-top: 25%">
        <h2>AngularJS template example</h2>
        <div id="nav" class="fourteen columns">
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/#!page1">Page 1</a></li>
            <li><a href="/#!page2">Page 2</a></li>
          </ul>
        </div>
        <div ng-controller="homeController">
          <div ng-view></div>
        </div>
      </div>
    </div>
  </div>

  <script src="modules/js/release.js?t=1556694960179"></script>

</body>

</html>
{{< /highlight >}}

and in release.js you can see that place holder ___REPLACE_IN_GULP___ is also updated with time stamp.

# Conclusion

Using Gulp I can create release version of my AngularJS web site, where all js and css files are minified and combined into single files, and where Cache bust is included, to force web browser to load new version.