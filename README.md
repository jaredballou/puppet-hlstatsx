# hlstatsx

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with hlstatsx](#setup)
    * [What hlstatsx affects](#what-hlstatsx-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hlstatsx](#beginning-with-hlstatsx)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manages the HLStatsX application

## Module Description

This module manages HLStatsX, a stat and log aggregator and interfacing tool
used with a number of online games based on the Source engine. The module installs
and provides defined types for managing installing, users, games, and servers.

## Setup

### What hlstatsx affects

* HLStatsX installation directory
* HLStatsX MySQL database/user/grants
* HLStatsX Apache vhost

### Setup Requirements **OPTIONAL**

None

### Beginning with hlstatsx

Just using class { 'hlstatsx': } will install MySQL, Apache, download the
application files, set up the database, import the standard MySQL schema and
default data, and create an admin user. Obviously, for anything past testing
the admin_pass and db_pass variables should be set to non-standard values.

## Usage

* class { 'hlstatsx': }
Base class that installs and configures an instance of HLStatsX
* hlstatsx::game
Manages a Game in the database
* hlstatsx::server
Manages a Server in the database
* hlstatsx::user
Manages a User in the database

## Reference

## Limitations

Only tested on CenOS 6.5

## Development

Feel free to fork, edit, and send back pull requests, I am pretty new to publishing
modules and appreciate any help or feedback.

## Release Notes/Contributors/Etc **Optional**

Initial release, works but might be rough, be careful if you use this over an existing
HLStatsX installation.
