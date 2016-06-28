# -*- coding: utf-8 -*-

rails_root = File.expand_path('../../', __FILE__)
ENV['BUNDLE_GEMFILE'] = rails_root + "/Gemfile"

# ワーカーの数
worker_processes 1

# ソケット
listen  "#{rails_root}/tmp/unicorn.sock"
pid     "#{rails_root}/tmp/unicorn.pid"

# ログ
log = "#{rails_root}/log/unicorn.log"
stderr_path File.expand_path('log/unicorn_stderr.log', rails_root)
stdout_path File.expand_path('log/unicorn_stdout.log', rails_root)

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

old_pid = "#{ server.config[:pid] }.oldbin"
unless old_pid == server.pid
  begin
   sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
   Process.kill :QUIT, File.read(old_pid).to_i
   rescue Errno::ENOENT, Errno::ESRCH
  end
end
end

after_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
