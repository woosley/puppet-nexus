# puppet-nexus

## Overview

this puppet module let you download files from nexus using a puppetized syntax

## Usage

this module provides a custom type called artifact.

*Example*

```puppet

 artifact {"apprunner":
    username   => $username, # nexus username
    password   => $password, # nexus password
    id         => 'app-runner', # artifact id
    repo       => 'central',    # nexus repo id
    group      => "com.danielflower.apprunner", # nexus group
    classifier => "",
    ensure     => present,
    version    => '1.1.1',
    name       => 'apprunner',
    extension  => 'jar',
    owner      => 'apprunner',
    path       => '/root',
    mode       => '0644'
  }
```

The example above will create a file `/root/apprunner-1.1.1.jar`. The rule of
the naming is `$name-$version.$extension`

You can also change the nexus url by pass 

```
    nexus => 'Your nexus api base url'
```

## notes

- this module is tested with ruby1.8 and ruby2.0
- this module is tested on Centos only but should work on most linux distribution
