module.exports = (grunt) ->
    require('time-grunt') grunt

    grunt.config.init
        clean:
            build: [
                'index.js'
                'lib'
            ]

        coffee:
            enju:
                expand: yes
                flatten: no
                cwd: 'src'
                src: ['**/*.coffee']
                dest: './'
                ext: '.js'

        watch:
            enju:
                files: ['src/**/*.coffee']
                tasks: ['coffee:enju']
                options:
                    spawn: no

    # -----------------------------------
    # tasks
    # -----------------------------------
    grunt.registerTask 'dev', ->
        grunt.task.run [
            'clean:build'
            'coffee:enju'
            'watch'
        ]

    grunt.registerTask 'build', ->
        grunt.task.run [
            'clean:build'
            'coffee:enju'
        ]

    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
