def password_gen(size=12)
  chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)  
  (1..size).collect{|a| chars[rand(chars.size)] }.join
end

dep "install drupal site", :sitename, :reponame, :dbname, :dbuser, :dbpass do
  sitename.ask("Domain name of the site to setup (do not specify www.)")
  reponame.default(sitename).ask("Enter the repository name, if different from the domain name")
  dbname.default(reponame).ask("Enter the Database Name, if different from the repository name")
  dbuser.default(reponame).ask("Enter the Database Username, if different from the repository name")
  dbpass.default('').ask("Enter the Database Password, if blank, one will be created for you")
  
  requires [
    "drupal database installed".with(:sitename => sitename, ),
    "drupal site code installed",
    "vhost configured",
    "webservers running"
    ]
  
  met? { false }
  meet { puts "foo #{sitename}" }
end

dep "drupal site code installed" do
  requires "github repo checked out", "drupal core installed"
end

dep "webservers running" do
  requires "nagey:running.nginx", "nagey:apache running"
end

dep "vhost configured" do
  requires "apache vhost configured","nginx vhost configured"
end

dep "nginx vhost configured", :sitename do
  requires "vhost configured.nginx".with(
        :domain => sitename,
        :domain_aliases => '', 
        :listen_host => '[::]', 
        :listen_port => '80', 
        :proxy_host => '8080',
        :enable_http => 'yes',
        :enable_https => 'no',
        :force_https => 'no',
        :nginx_prefix => "/usr/local/"
        )
end

dep "apache vhost configured" do

end