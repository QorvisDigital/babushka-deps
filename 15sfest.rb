dep '15sfestWeb' do
  web_hostname = "15sfest.com"
  listen_port = 80
  requires [ 
    "hostname configured".with(:myhostname => web_hostname),
    "nagey:vhost enabled.nginx".with(
      :domain => web_hostname,
      :vhost_type => "websocket_proxy",
      :path => md_web_dir(package),
      :nginx_prefix => "/usr/local/nginx",
      :domain_aliases => '',
      :force_https => 'no',
      :enable_https => 'no',
      :listen_host => "*",
      :listen_port => listen_port,
      :proxy_port => 3000,
      :proxy_host => "localhost"
    ),
    "nagey:running.nginx".with(:nginx_prefix => "/usr/local/nginx")
  ]
end

dep "hostname configured", :myhostname do
  met? { shell?("cat /etc/hosts|grep #{myhostname}") || shell?("host #{myhostname}") }
  meet { sudo "echo '127.0.0.1 #{myhostname}' >> /etc/hosts" }
end
