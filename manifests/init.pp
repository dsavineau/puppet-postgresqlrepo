# == Class: postgresqlrepo
#
# A puppet module that configure the PostgreSQL repository on an Enterprise Linux (and relatives) system
#
# === Parameters
#
# [*version*]
#   (float) PostgreSQL version number
#   Possible value: 8.4, 9.0, 9.1, 9.2, 9.3
#   Default: 9.3
#
# [*repo_enable*]
#   (boolean) Should the main repo be enabled
#   Default: true
#
# [*repo_source_enable*]
#   (boolean) Should the srpms repo should be enabled.
#   Default: false
#
# === Examples
#
#  include postgresqlrepo
#
#    or
#
#  class { 'postgresqlrepo' :
#   version             => '9.1',
#   repo_source_enable  => true,
#  }
#
# === Authors
#
# Yanis Guenane <yguenane@gmail.com>
#
# === Copyright
#
# Copyright 2014 Yanis Guenane
#
class postgresqlrepo (
  $version            = '9.3',
  $repo_enable        = true,
  $repo_source_enable = false,
) {

  include stdlib

  $version_alt = regsubst($version, '^(\d+)\.(\d+)$', '\1\2')

  if ! ($::operatingsystem in ['RedHat', 'Fedora', 'CentOS']) {
    fail ("This module does not support your operating system : ${::operatingsystem}")
  }

  $os = $::operatingsystem ? {
    'Fedora'        => 'fedora',
    /RedHat|CentOS/ => 'redhat',
  }
  $os_shortname = $::operatingsystem ? {
    'Fedora'        => 'fedora',
    /RedHat|CentOS/ => 'rhel',
  }

  yumrepo { "pgdg${version_alt}" :
    descr    => "PostgreSQL ${version} \$releasever - \$basearch",
    baseurl  => "http://yum.postgresql.org/${version}/${os}/${os_shortname}-\$releasever-\$basearch",
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-${version_alt}",
    gpgcheck => 1,
    enabled  => bool2num($repo_enable),
  }

  yumrepo { "pgdg${version_alt}-source" :
    descr    => "PostgreSQL ${version} \$releasever - \$basearch - Source",
    baseurl  => "http://yum.postgresql.org/srpms/${version}/${os}/${os_shortname}-\$releasever-\$basearch",
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-${version_alt}",
    gpgcheck => 1,
    enabled  => bool2num($repo_source_enable),
  }

  file {"/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-${version_alt}" :
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/postgresqlrepo/RPM-GPG-KEY-PGDG-${version_alt}",
  }

  postgresqlrepo::rpm_gpg_key {"PGDG-${version_alt}":
    path   => "/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-${version_alt}",
    before => Yumrepo["pgdg${version_alt}", "pgdg${version_alt}-source"],
  }

}
