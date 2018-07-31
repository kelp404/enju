module.exports = (grunt) ->
    require('time-grunt') grunt

    grunt.config.init
        clean:
            build: [
                'index.js'
                'lib'
            ]
            test: 'tests/*.js'

        coffee:
            enju:
                expand: yes
                flatten: no
                cwd: 'src'
                src: ['**/*.coffee']
                dest: './'
                ext: '.js'
            test:
                expand: yes
                flatten: no
                cwd: 'tests'
                src: ['**/*.coffee']
                dest: './tests'
                ext: '.js'

        watch:
            enju:
                files: ['src/**/*.coffee']
                tasks: ['coffee:enju']
                options:
                    spawn: no

    grunt.registerTask 'dev', ->
        grunt.task.run [
            'clean:build'
            'coffee:enju'
            'watch'
        ]

    grunt.registerTask 'build', ->
        grunt.task.run [
            'clean'
            'coffee'
        ]

    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
