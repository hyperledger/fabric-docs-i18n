## Example Usage

### Get Level Usage

Here is an example of the `peer logging getlevel` command:

  * To get the log level for logger `peer`:

    ```
    peer logging getlevel peer

    2018-11-01 14:18:11.276 UTC [cli.logging] getLevel -> INFO 001 Current log level for logger 'peer': INFO

    ```

### Get Log Spec Usage

Here is an example of the `peer logging getlogspec` command:

  * To get the active logging spec for the peer:

    ```
    peer logging getlogspec

    2018-11-01 14:21:03.591 UTC [cli.logging] getLogSpec -> INFO 001 Current logging spec: info

    ```

### Set Level Usage

Here are some examples of the `peer logging setlevel` command:

  * To set the log level for loggers matching logger name prefix `gossip` to
    log level `WARNING`:

    ```
    peer logging setlevel gossip warning
    2018-11-01 14:21:55.509 UTC [cli.logging] setLevel -> INFO 001 Log level set for logger name/prefix 'gossip': WARNING
    ```

  * To set the log level to `ERROR` for only the logger that exactly matches the
    supplied name, append a period to the logger name:

    ```
    peer logging setlevel gossip. error

    2018-11-01 14:27:33.080 UTC [cli.logging] setLevel -> INFO 001 Log level set for logger name/prefix 'gossip.': ERROR
    ```

### Set Log Spec Usage

Here is an example of the `peer logging setlogspec` command:

  * To set the active logging spec for the peer where loggers that begin with
    `gossip` and `msp` are set to log level `WARNING` and the default for all
    other loggers is log level `INFO`:

    ```
    peer logging setlogspec gossip=warning:msp=warning:info

    2018-11-01 14:32:12.871 UTC [cli.logging] setLogSpec -> INFO 001 Current logging spec set to: gossip=warning:msp=warning:info

    ```

    Note: there is only one active logging spec. Any previous spec, including
    modules updated via 'setlevel', will no longer be applicable.

### Revert Levels Usage

Here is an example of the `peer logging revertlevels` command:

  * To revert the logging spec to the start-up value:

    ```
    peer logging revertlevels

    2018-11-01 14:37:12.402 UTC [cli.logging] revertLevels -> INFO 001 Logging spec reverted to the peer's spec at startup.

    ```

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
