#!/usr/bin/env python
import os
import sys

from deluge.config import Config
from deluge.log import setup_logger


def main():
    setup_logger()
    config_file = "/config/core.conf"
    c = Config(config_file)
    c.load()
    if not c.config:
        print(f"failed to load config file {config_file}", file=sys.stderr)
        return 1

    c.config["allow_remote"] = True

    downloads = "/downloads"
    c.config["download_location"] = downloads
    c.config["move_completed_path"] = downloads
    c.config["torrentfiles_location"] = downloads

    try:
        ports = [int(p) for p in os.environ["LISTEN_PORTS"].split("-")]
    except ValueError as err:
        print(f"failed to parse LISTEN_PORTS: {err}", file=sys.stderr)
        return 1
    except KeyError:
        c.save()
        return 0

    if len(ports) == 1:
        ports *= 2
    elif len(ports) > 2:
        print(f"cannot specify more than 2 ports: {ports}", file=sys.stderr)
        return 1

    c.config["listen_ports"] = ports
    c.config["random_port"] = True

    c.save()
    return 0


if __name__ == "__main__":
    sys.exit(main())
