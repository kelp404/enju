module.exports = (grunt) ->
    require('time-grunt') grunt
    require('load-grunt-tasks') grunt

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
                cwd: '__tests__'
                src: ['**/*.coffee']
                dest: './__tests__'
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
