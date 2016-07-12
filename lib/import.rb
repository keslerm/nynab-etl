require 'json'
require 'pg'
require 'logger'
require 'yaml'

# Load login details
config = YAML.load_file 'config.yml'

log = Logger.new STDOUT

connection = PG::Connection.new host: config['database']['host'], dbname: config['database']['name'],
                                user: config['database']['username'], password: config['database']['password']

tables_to_import = %w(be_account_calculations be_account_mappings be_accounts be_master_categories
be_monthly_account_calculations be_monthly_budget_calculations be_monthly_budgets
be_monthly_subcategory_budget_calculations be_monthly_subcategory_budgets be_payee_locations be_payee_rename_conditions
be_payees be_scheduled_subtransactions be_scheduled_transactions be_settings be_subcategories be_subtransactions
be_transactions)

json_input = JSON.parse File.read 'output.json'

log.info 'Creating import schema'

connection.exec 'drop schema import cascade;'
connection.exec 'create schema import;'

tables_to_import.each do |table|
  log.info "Creating temporary json table for #{table}"

  connection.exec "create table import.#{table} ( data json )"

  log.info 'Loading data into temporary table'

  count = 0
  json_input['changed_entities'][table].each do |value|
    raw_value = value.to_json
    connection.exec_params "insert into import.#{table} (data) values ($1)", [ raw_value ]
    count+= 1
  end

  log.info "Loaded #{count} rows into #{table}"
end




