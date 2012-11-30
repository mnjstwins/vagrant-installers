class zlib(
  $autotools_environment = {},
  $file_cache_dir = params_lookup('file_cache_dir', 'global'),
  $prefix = params_lookup('prefix'),
) {
  require build_essential

  $source_filename  = "zlib-1.2.7.tar.gz"
  $source_url = "http://zlib.net/${source_filename}"
  $source_file_path = "${file_cache_dir}/${source_filename}"
  $source_dir_name  = regsubst($source_filename, '^(.+?)\.tar\.gz$', '\1')
  $source_dir_path  = "${file_cache_dir}/${source_dir_name}"

  # Determine if we have an extra environmental variables we need to set
  # based on the operating system.
  if $operatingsystem == 'Darwin' {
    $extra_autotools_environment = {
      "LDFLAGS" => "-Wl,-install_name,@rpath/libz.dylib",
    }
  } else {
    $extra_autotools_environment = {}
  }

  # Merge our environments.
  $real_autotools_environment = autotools_merge_environments(
    $autotools_environment, $extra_autotools_environment)

  #------------------------------------------------------------------
  # Compile
  #------------------------------------------------------------------
  wget::fetch { "libz":
    source      => $source_url,
    destination => $source_file_path,
  }

  exec { "untar-libz":
    command => "tar xvzf ${source_file_path}",
    creates => $source_dir_path,
    cwd     => $file_cache_dir,
    require => Wget::Fetch["libz"],
  }

  autotools { "libz":
    configure_flags    => "--prefix=${prefix}",
    configure_sentinel => "${source_dir_path}/zlib.pc",
    cwd                => $source_dir_path,
    environment        => $real_autotools_environment,
    require            => Exec["untar-libz"],
  }
}
