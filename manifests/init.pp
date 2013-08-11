$drupalurl = "http://ftp.drupal.org/files/projects/drupal-7.23.tar.gz"
$drupalver = "drupal-7.23"
$puppetver = "2.7.22-1puppetlabs1"
$db_password = "time2shine"

exec { "update":
  command => "apt-get update",
  path    => "/usr/bin"
}

package { ["apache2", "mysql-server", "git-core", "php5", "php5-mysql", "php5-gd"]:
  ensure => present,
  require => Exec["update"],
  before => [Exec["createdb"], File["/var/www/drupal"], File["/etc/apache2/conf.d/drupal.conf"]]
}

service { "apache2":
  ensure => running,
}

file { "/etc/apache2/conf.d/drupal.conf":
  ensure => present,
  owner => "www-data",
  notify => Service["apache2"],
  content => "NameVirtualHost *:80
<Directory /var/www/drupal/current>
  AllowOverride All
  Order Allow,Deny
  Allow from all
</Directory>
<VirtualHost *:80>
  DocumentRoot /var/www/drupal/current
  ServerName local.drupalground.com
</VirtualHost>"
}

file { "/var/www/drupal":
  ensure => directory,
  owner => "www-data"
}
exec { "wgetdrupal":
  command => "wget ${drupalurl}",
  creates => "/var/www/drupal/${drupalver}.tar.gz",
  cwd => "/var/www/drupal",
  path => "/usr/bin",
  require => File["/var/www/drupal"]
}
exec { "unzipdrupal":
  command => "tar xvfz ${drupalver}.tar.gz",
  cwd     => "/var/www/drupal",
  path    => "/bin",
  creates => "/var/www/drupal/${drupalver}",
  require => Exec["wgetdrupal"]
}
exec { "chowndrupal":
  command => "chown -R www-data:www-data /var/www/drupal",
  path    => ["/usr/bin", "/bin"],
  require => Exec["cpsettings"],
}
file { "/var/www/drupal/${drupalver}/sites/default/files":
  owner => "www-data",
  ensure => directory,
  require => Exec["cpsettings"]
}
exec { "cpsettings":
  command => "cp default.settings.php settings.php",
  cwd => "/var/www/drupal/${drupalver}/sites/default",
  path => ["/bin", "/usr/bin"],
  creates => "/var/www/drupal/${drupalver}/sites/default/settings.php",
  require => Exec["unzipdrupal"]
}

file { "/var/www/drupal/current":
  ensure => link,
  target => "/var/www/drupal/${drupalver}",
  require => Exec["unzipdrupal"]
}

exec { "createdb": 
  command => "echo \"CREATE DATABASE drupal; CREATE USER 'drupal_user'@'localhost' IDENTIFIED BY '${db_password}'; GRANT ALL PRIVILEGES ON drupal.* TO 'drupal_user'@'localhost'; FLUSH PRIVILEGES;\" | mysql -u root",
  path => ["/bin", "/usr/bin"],
  onlyif => "echo 'show databases;' | mysql -u root | grep drupal | awk '{print length}'"
} 
