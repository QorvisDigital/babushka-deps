def password_gen(size=12)
  chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)  
  (1..size).collect{|a| chars[rand(chars.size)] }.join
end

dep "install drupal site" :sitename, :reponame, :dbname, :dbuser, :dbpass do
  sitename.default('').ask("Domain name of the site to setup (do not specify www.)")
  reponame.default(sitename).ask("Enter the repository name, if different from the domain name")
  dbname.default(reponame).ask("Enter the Database Name, if different from the repository name")
  dbuser.default(reponame).ask("Enter the Database Username, if different from the repository name")
  dbpass.default('').ask("Enter the Database Password, if blank, one will be created for you")
end