# nYNAB Data Export
This is a small collection of scripts/sql/mess that I'm using to export my nYNAB data from an undocumented API and loading it into a postgres database.

This is a slapped together hack so please excuse the disastrous state it is in.

## Instructions
1. Copy config.yml.example to config.yml
2. Edit config.yml values with your username and password
3. Run `bundle install`
4. Run `bundle exec ruby lib/export.rb`
5. Run `bundle exec ruby lib/import.rb`
6. Run `psql -h localhost -u whatever -f etl.sql dbname`

It will generate output.json which is the mass of data for your whole account

## Progress
DONE Export data from YNAB API
DONE Import data from export into a staging schema
TODO Write ETL process to move raw JSON data into relational table structure
TODO De-normalize data for easy consumption

### Tables
These are the "tables" defined in the YNAB data and which ones I've written ETL for to load them into RDS tables.

#### Completed
be_subcategories
be_payee_rename_conditions
be_accounts
be_payees
be_transactions

#### TODO
be_account_calculations
be_account_mappings
be_master_categories
be_monthly_account_calculations
be_monthly_budget_calculations
be_monthly_budgets
be_monthly_subcategory_budget_calculations
be_monthly_subcategory_budgets
be_settings
be_subtransactions
be_payee_locations
be_scheduled_subtransactions
be_scheduled_transactions

## Use Case
I'm using this to automate some reports that get emailed out. YNAB offers an "export" function but there's no way to really easily automate it so I got bored and wrote this.

Other potential cases? Maybe data backup incase you one day want to change services you could format your data for inserting there? 

The sky is the limit.

## Disclaimer
Given that this is using an internal API for YNAB this could break at anytime. If it does, don't blame me - maybe ask YNAB for a public API.