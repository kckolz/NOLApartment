web_directory = '/www'
app_directory = "#{web_directory}/NOLApartment"

working_directory "#{app_directory}"
pid "#{web_directory}/shared/unicorn/tmp/unicorn.pid"
stderr_path "#{web_directory}/shared/unicorn/logs/unicorn.log"
stdout_path "#{web_directory}/shared/unicorn/logs/unicorn.log"

listen "#{web_directory}/shared/unicorn/tmp/unicorn.nolapartment.sock"
worker_processes 2
timeout 30
