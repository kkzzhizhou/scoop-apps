#!/usr/bin/env python3
import argparse
#from urllib.parse import unquote


def main(name, version, link):
    pattern = ("://", "#/", "/", "%", " ", "+")
#    link = unquote(link)
    for elem in pattern:
        link = link.replace(elem, "_")
    print(name + "#" + version + "#" + link)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="This program compute scoop cache file name")
    parser.add_argument("-n", "--name", dest="name", required=True, help="Scoop software name")
    parser.add_argument("-v", "--version", dest="version", required=True, help="Scoop software version")
    parser.add_argument("-l", "--link", dest="link", required=True, help="Scoop software download url")

    args = parser.parse_args()

    main(args.name, args.version, args.link)
