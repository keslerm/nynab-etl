nYNAB Data Export
=======================
This is a small collection of scripts/sql/mess that I'm using to export my nYNAB data from an undocumented API and loading it into a postgres database.

Instructions
-----------------------
1. Copy config.yml.example to config.yml
2. Edit config.yml values with your username and password
3. Run `bundle install`
4. Run `bundle exec ruby lib/export.rb`

It will generate output.json which is the mass of data for your whole account
