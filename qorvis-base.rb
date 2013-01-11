def orgname
  "QorvisDigital"
end

def github_repo_url(reponame)
  "git@github.com:#{orgname}/#{reponame}.git"
end

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
    "drupal database installed".with(:sitename => sitename ),
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
  requires "nagey:vhost configured.nginx".with(
        :domain => sitename,
        :domain_aliases => '', 
        :listen_host => '127.0.0.1', 
        :listen_port => '80', 
        :proxy_host => 'localhost',
        :proxy_port => '8000',
        :enable_http => 'yes',
        :enable_https => 'no',
        :force_https => 'no',
        :nginx_prefix => "/usr/local/",
        :vhost_type => "proxy"
        )
end

dep "apache vhost configured" do

end

dep "github repo checked out", :reponame do
  reponame.ask("Please enter the name of the repository")
  requires "src dir exists", "ssh key exists", "ssh key authorized", "git"
  met? { shell? "ls -l #{File.expand_path("~/src/"+reponame)}" }
  meet { shell "git clone #{github_repo_url(reponame)} ~/src/#{reponame}" }
end

dep "github repo up-to-date", :reponame do
  requires "github repo checked out".with(reponame), "git"
  met? do
    shell "cd #{File.expand_path("~/src/"+reponame)}; git remote update"
    shell("cd #{File.expand_path("~/src/"+reponame)}; git status -uno -sb") =~ /behind/
  end
  meet { log_shell "Updating Git Repo", "cd #{File.expand_path("~/src/"+reponame)}; git pull" }
end

dep "src dir exists" do
  met? { shell? "ls -l #{File.expand_path("~/src")}" }
  meet { shell "mkdir -p #{File.expand_path("~/src")}"}
end

dep "ssh key authorized", :something do
  met? do
    k = shell "cat #{File.expand_path("~/.ssh/id_*.pub")}"
    something.ask "Has the key \n #{k} \n been authorized as a deployment key (say y, then y again if so)?"
    true if something == 'y'
  end
  meet { true }
end

dep "ssh key exists", :something do
  met? do
    shell? "ls -l #{File.expand_path("~/.ssh/id*pub")}" 
  end
  meet do
    shell "ssh-keygen -t rsa -f #{File.expand_path("~/.ssh/id_rsa")} -N ''"
  end
end


dep "drupal core installed", :version do
  
end
