module.exports = function (grunt) {
    grunt.initConfig({
        /*  Running `grunt less` will compile once
            https://github.com/gruntjs/grunt-contrib-less
        */
        less: {
            development: {
                options: {
                    paths: ["./_public/theme-sample-site/css"],
                    compress: true
                },
                files: {
                    "./_public/theme-sample-site/css/theme-sample-site.css":"./_public/theme-sample-site/css/main.less"
                }
            }
        },
        /*  Running `grunt watch` will watch for changes
            https://github.com/gruntjs/grunt-contrib-watch*/
        watch: {
            files: "./_public/**/css/*.less",
            tasks: ["less"]
        }
    });
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-watch');
};

