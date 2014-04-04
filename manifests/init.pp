$version = "8.x-dev"

$drupalurl = "http://ftp.drupal.org/files/projects/drupal-$version.tar.gz"
$drupalver = "drupal-$version"
$puppetver = "2.7.22-1puppetlabs1"
$db_password = "time2shine"
$home = "/home/vagrant"
$drushurl = "https://github.com/drush-ops/drush/archive/7.x-5.x.tar.gz"
$drushversion = "drush-7.x-5.x"

exec { "update":
  command => "apt-get update",
  path    => "/usr/bin"
}

package { ["apache2", "mysql-server", "git-core", "php5", "php5-mysql", "php5-gd", "php5-cli"]:
  ensure => present,
  require => Exec["update"],
  before => [Exec["createdb"], User["www-data"], File["/etc/apache2/conf.d/drupal.conf"]]
}

service { "apache2":
  ensure => running,
}

file { "/etc/apache2/conf.d/drupal.conf":
  ensure => present,
  owner => "www-data",
  notify => Service["apache2"],
  content => "NameVirtualHost *:80
<Directory /var/www/current>
  AllowOverride All
  Order Allow,Deny
  Allow from all
</Directory>
<VirtualHost *:80>
  DocumentRoot /var/www/current
  ServerName local.drupalground.com
</VirtualHost>"
}

file { "${home}/www":
  ensure => directory,
  owner => "www-data"
}

file { "/var/www":
  ensure => directory,
  owner => "www-data",
  before => File["/var/www/current"]
}
exec { "wgetdrupal":
  command => "wget ${drupalurl}",
  creates => "${home}/www/${drupalver}.tar.gz",
  cwd => "${home}/www",
  path => "/usr/bin",
  require => File["${home}/www"]
}
exec { "unzipdrupal":
  command => "tar xvfz ${drupalver}.tar.gz",
  cwd     => "${home}/www",
  path    => "/bin",
  creates => "${home}/www/${drupalver}",
  require => Exec["wgetdrupal"]
}
exec { "wgetdrush":
  command => "wget -c ${drushurl} --output-document=drush.tar.gz",
  creates => "${home}/drush.tar.gz",
  path    => "/usr/bin",
  cwd     => $home
}
exec { "unzipdrush":
  command => "tar xvfz drush.tar.gz",
  creates => "${home}/drush/drush",
  path    => "/bin",
  cwd     => $home,
  require => Exec["wgetdrush"]
}

exec { "linkdrush":
  command => "ln -s ${home}/${drushversion}/drush /usr/bin/drush",
  creates => "/usr/bin/drush",
  path    => ["/usr/bin", "/bin"],
  cwd     => $home,
  require => Exec["unzipdrush"]
}

/*
exec { "chowndrupal":
  command => "chown -R www-data:www-data /home/vagrant/www",
  path    => ["/usr/bin", "/bin"],
  require => Exec["cpsettings"],
}
*/
exec { "chmoddrupal":
  command => "chmod -R 774 ${home}/www",
  path    => ["/usr/bin", "/bin"],
  require => Exec["cpsettings"]
}
user { "www-data" :
  ensure => present,
  groups => ["vagrant"]
}

file { "${home}/www/${drupalver}/sites/default/files":
  owner => "www-data",
  ensure => directory,
  before => Exec["chmoddrupal"],
  require => Exec["cpsettings"]
}
exec { "cpsettings":
  command => "cp default.settings.php settings.php",
  cwd => "${home}/www/${drupalver}/sites/default",
  path => ["/bin", "/usr/bin"],
  creates => "${home}/www/${drupalver}/sites/default/settings.php",
  require => Exec["unzipdrupal"]
}

file { "/var/www/current":
  ensure => link,
  target => "${home}/www/${drupalver}",
  require => Exec["unzipdrupal"]
}

exec { "createdb": 
  command => "echo \"CREATE DATABASE drupal; CREATE USER 'drupal_user'@'localhost' IDENTIFIED BY '${db_password}'; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal_user'@'localhost'; FLUSH PRIVILEGES;\" | mysql -u root",
  path => ["/bin", "/usr/bin"],
  onlyif => "echo 'show databases;' | mysql -u root | grep drupal | awk '{print length}'"
} 
