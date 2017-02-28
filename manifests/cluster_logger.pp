# == Class: pure_repmgr::cluster_logger
#
# Installs cluster_logger for cluster aware state logging
class pure_repmgr::cluster_logger
(
) inherits pure_repmgr
{

  file { "${pure_postgres::pg_etc_dir}/cluster_logger.ini":
    ensure  => file,
    content => epp('pure_repmgr/cluster_logger.epp'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace =>  false,
    notify  => Service['pure_cluster_logger.service'],
  } ->

  file { ['/usr/pgpure/cluster_logger', '/var/log/pgpure/cluster_logger' ]:
    ensure => directory,
    owner  => $pure_postgres::postgres_user,
    group  => $pure_postgres::postgres_group,
  } ->

  file {'/usr/pgpure/cluster_logger/pure_cluster_logger.py':
    path    => '/usr/pgpure/cluster_logger/pure_cluster_logger.py',
    ensure  => 'file',
    content => epp('pure_repmgr/pure_cluster_logger.epp'),
    owner   => $pure_postgres::postgres_user,
    group   => $pure_postgres::postgres_group,
    mode    => '0750',
    notify  => Service['pure_cluster_logger.service'],
  } ->

  file {'/usr/lib/systemd/system/pure_cluster_logger.service':
    path   => '/usr/lib/systemd/system/pure_cluster_logger.service',
    ensure => 'file',
    source => 'puppet:///modules/pure_repmgr/pure_cluster_logger.service',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Exec['systemctl daemon-reload'],
  } ->

  service { 'pure_cluster_logger.service':
    ensure => 'running',
    enable => true,
  }

  if ! defined(Exec['systemctl daemon-reload']) {
    exec { 'systemctl daemon-reload':
      refreshonly => true,
      cwd         => '/',
      path        => '/bin'
    }
  }

}
