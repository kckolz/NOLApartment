require 'json'

web_directory = '/www'

env_file = File.join(web_directory, 'nolapartment.env')
if File.exists? env_file
  file = File.new env_file
  envs = JSON.parse file.read

  envs.each do |k, v|
    ENV[k] = v
  end
end

app_directory = "#{web_directory}/NOLApartment"

working_directory "#{app_directory}"
pid "#{web_directory}/shared/unicorn/tmp/unicorn.pid"
stderr_path "#{web_directory}/shared/unicorn/logs/unicorn.log"
stdout_path "#{web_directory}/shared/unicorn/logs/unicorn.log"

listen "#{web_directory}/shared/unicorn/tmp/unicorn.nolapartment.sock"
worker_processes 2
timeout 30
