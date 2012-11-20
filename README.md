Octosh
=====

[![Build Status](https://secure.travis-ci.org/BrianMMcClain/octosh.png)](http://travis-ci.org/BrianMMcClain/octosh)

For when you feel like you need eight arms to manage your servers

Octosh (Pronounced "awk-tawsh", short for "Octo-shell") is a tool for interacting with multiple hosts simultaneously either in a scripted manner or an interactive manner.


INSTALL
-------

```gem install octosh```





USAGE
-----

In scripted usage, you may either inline your script or pass a path to a script, which will then be executed on each host that is specified.

The quickest way to get up and running is using inline scripting. For example…

```octosh -b "hostname; date" -r 192.168.0.100,192.168.0.101,192.168.0.102```

A few notes, the assumed user here, since none has been specified, is `root`. If you want to specify a uer per host, the command becomes…

```octosh -b "hostname; date" -r user1@192.168.0.100,user2@192.168.0.101,user3@192.168.0.102```

or if you want to specify a universal user for all hosts…

```octosh -b "hostname; date" -u someuser -r 192.168.0.100,192.168.0.101,192.168.0.102```

By default, this will prompt for a password for each host. You can also indicate that the password is uniform cross all hosts, in which case the command becomes…


```octosh -b "hostname; date" -u someuser -p -r 192.168.0.100,192.168.0.101,192.168.0.102```


Instead of inline scripting, you can also pass a path to a script to run on each host, like so…

```octosh -s /path/to/script -u someuser -p -r 192.168.0.100,192.168.0.101,192.168.0.102```

There's also...


INTERACTIVE MODE
----------------

Interactive mode can be activate with the `-i` flag, for example...

```octosh -i -u someuser -p -r 192.168.0.100,192.168.0.101,192.168.0.102```

You will be prompted for the password(s), and then be greeted by the Octoshell prompt. From here, you can operate as normal as you would on a single server, but all commands will be ran on all servers, color-coded per server.

There are a few special commands however (IN PROGRESS)…

* `put PATH` -- Upload file at PATH to the CWD on the remote hosts
* `get FILE` -- Download FILE to the CWD on the local machine. Files will be stored in the format "FILENAME-HOST.EXT"
* `exit` -- Cleanly close the conneciton to all servers and quit OSH




ROADMAP
-------

* Public Key Authentication
* Interactive shell with Octosh-specific commands (put, get, read, etc)
* Simple DSL for more complex tasks 