def webdir
  "/var/www/html"
end

def appdir
  "/var/www/app"
end

def srcdir
  File.expand_path("~/src/15sfest")
end


dep '15sfestWeb' do
  web_hostname = "15sfest.com"
  listen_port = 80
  requires [ 
    "15sfest-system-deps",
    "hostname configured".with(:myhostname => web_hostname),
    "nagey:vhost enabled.nginx".with(
      :domain => web_hostname,
      :vhost_type => "websocket_proxy",
      :path => webdir,
      :nginx_prefix => "/usr/local/nginx",
      :domain_aliases => '',
      :force_https => 'no',
      :enable_https => 'no',
      :listen_host => "*",
      :listen_port => listen_port,
      :proxy_port => 3000,
      :proxy_host => "localhost"
    ),
    "nagey:running.nginx".with(:nginx_prefix => "/usr/local/nginx"),
    "15sfest build"
  ]
end

dep "hostname configured", :myhostname do
  met? { shell?("cat /etc/hosts|grep #{myhostname}") || shell?("host #{myhostname}") }
  meet { sudo "echo '127.0.0.1 #{myhostname}' >> /etc/hosts" }
end

dep "15sfest updated" do
  requires "15sfest cloned"
  
  met? do
    shell "cd #{srcdir}; git remote update"
    true unless shell("cd #{srcdir}; git status -uno -sb") =~ /behind/
  end
  
  meet do
    log_shell "Updating Git Repository", "cd #{srcdir}; git pull"
  end
end 

dep "15sfest cloned" do
  requires "15sfest-srcdir", "15sfest-appdir", "15sfest-gitdir", "git"
  
  git_url = "git@github.com:nagey/ouiff.git"
  
  met? { File.exists? "#{srcdir}/.git/config" }
  meet do
    shell "git clone #{git_url} #{srcdir}"
  end
end

dep "15sfest build" do
  requires "15sfest updated", "15sfest build-web", "15sfest build-app"
end

dep "15sfest build-web" do
  requires "grunt", "bower", "npm", "15sfest build-web-task"
end

dep "15sfest build-web-task" do 
  requires "grunt", "npm"
  shell "cd #{srcdir}/html; npm install && bower install && grunt && rm -rf #{webdir}/* && cp -pr #{srcdir}/html/dist/* #{webdir}"
end

dep "15sfest build-app" do
  requires "npm", "nodejs.src", "15sfest build-app-task"
end

dep "15sfest build-app-task" do 
  sudo "cd #{srcdir}/app; killall -9 node; cp -pr #{srcdir}/app/* #{appdir}; npm install && npm start"
end

dep "npm" do
  requires "nagey:nodejs.src", "npm globals path"
end

dep "npm globals path" do
  met? { shell? "echo $PATH|grep npm" }
  meet { 
    sudo 'echo "PATH=$PATH:/usr/local/share/npm/bin" >> /etc/profile' 
  }
end

dep "grunt" do
  requires "npm", "phantomjs", "compass"
  met? { shell? "which grunt" }
  meet { sudo "npm install -g grunt-cli" }
end

dep "compass" do
  met? { shell? "gem list | grep -i compass" }
  meet { sudo "gem install compass" }
end

dep "bower" do
  requires "npm"
  met? { shell? "which bower" }
  meet { sudo "npm install -g bower" }
end

dep "phantomjs" do
  requires "npm"
  met? { shell? "which phantomjs" }
  meet { sudo "npm install -g phantomjs" }
end

dep '15sfest-srcdir' do
  met? { File.exists? File.expand_path(webdir) }
  meet { sudo "mkdir -p #{webdir}" }
end

dep '15sfest-appdir' do
  met? { File.exists? File.expand_path(appdir) }
  meet { sudo "mkdir -p #{appdir}" }
end

dep '15sfest-gitdir' do
  met? { File.exists? File.expand_path(srcdir) }
  meet { shell "mkdir -p #{srcdir}" }
end

dep "15sfest-system-deps" do
  requires "mongodb.managed", "daemontools.managed", "redis"
end

dep "mongodb.managed" do
  provides "mongod"
end

dep "daemontools.managed" do
  provides "svc", "supervise", "svscan"
end

dep "redis" do
  requires "redis-server.managed" unless Babushka::host.osx?
  requires "redis.managed" if Babushka::host.osx?
end

dep "redis-server.managed" do
  provides "redis-server"
end

dep "redis.managed" do
  provides "redis-server"
end
