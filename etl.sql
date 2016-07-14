/* Tables to import
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

DONE
be_subcategories
be_payee_rename_conditions
be_accounts
be_payees
be_transactions
 */

/* Schema */
drop table if exists be_accounts;
create table be_accounts (
  id varchar primary key,
  is_tombstone boolean,
  account_type varchar,
  account_name varchar,
  last_entered_check_number varchar,
  last_reconciled_date varchar, -- No data
  last_reconciled_balance varchar,
  hidden boolean,
  sortable_index integer,
  on_budget boolean,
  note varchar,
  direct_connect_enabled boolean,
  direct_connect_institution_id varchar,
  direct_connect_account_id varchar,
  direct_connect_last_imported_at timestamp,
  direct_connect_last_error_code varchar
);

drop table if exists be_payees;
create table be_payees (
  id varchar primary key,
  is_tombstone boolean,
  entities_account_id varchar,
  enabled bool,
  auto_fill_subcategory_id varchar,
  auto_fill_memo varchar,
  auto_fill_amount integer,
  name varchar,
  internal_name varchar,
  auto_fill_subcategory_enabled boolean,
  auto_fill_amount_enabled boolean,
  auto_fill_memo_enabled boolean,
  rename_on_import_enabled boolean
);

drop table if exists be_transactions;
create table be_transactions (
  id varchar primary key,
  ynab_id varchar,
  is_tombstone boolean,
  source varchar,
  entities_account_id varchar,
  entities_payee_id varchar,
  entities_subcategory_id varchar,
  entities_scheduled_transaction_id varchar,
  imported_payee varchar,
  transaction_date date,
  imported_date date,
  date_entered_from_schedule varchar,
  amount integer,
  cash_amount integer,
  credit_amount integer,
  subcategory_credit_amount_preceding integer,
  memo varchar,
  cleared varchar,
  accepted boolean,
  check_number varchar,
  flag varchar,
  transfer_account_id varchar,
  transfer_transaction_id varchar,
  transfer_subtransaction_id varchar,
  matched_transaction_id varchar
);

drop table if exists be_payee_rename_conditions;
create table be_payee_rename_conditions (
  id varchar primary key,
  entities_payee_id varchar,
  is_tombstone boolean,
  operator varchar,
  operand varchar
);

drop table if exists be_subcategories;
create table be_subcategories (
  id varchar PRIMARY KEY,
  entities_master_category_id varchar,
  is_tombstone boolean,
  internal_name varchar,
  name varchar,
  type varchar,
  sortable_index integer,
  note varchar,
  entities_account_id varchar,
  goal_type varchar,
  goal_creation_month varchar,
  target_balance integer,
  target_balance_month varchar,
  monthly_funding integer,
  is_hidden boolean
);

/* ETL Process */
insert into be_accounts (
  select
    data->>'id',
    cast(data->>'is_tombstone' as boolean),
    data->>'account_type',
    data->>'account_name',
    data->>'last_entered_check_number',
    data->>'last_reconciled_date', -- No data
    data->>'last_reconciled_balance',
    cast(data->>'hidden' as boolean),
    cast(data->>'sortable_index' as integer),
    cast(data->>'on_budget' as boolean),
    data->>'note',
    cast(data->>'direct_connect_enabled' as boolean),
    data->>'direct_connect_institution_id',
    data->>'direct_connect_account_id',
    cast(data->>'direct_connect_last_imported_at' as timestamp),
    data->>'direct_connect_last_error_code'
  from import.be_accounts
);

insert into be_payees (
  SELECT
    data ->> 'id',
    cast(data ->> 'is_tombstone' as boolean),
    data ->> 'entities_account_id',
    cast(data ->> 'enabled' as boolean),
    data ->> 'auto_fill_subcategory_id',
    data ->> 'auto_fill_memo',
    cast(data ->> 'auto_fill_amount' as integer),
    data ->> 'name',
    data ->> 'internal_name',
    cast(data ->> 'auto_fill_subcategory_enabled' as boolean),
    cast(data ->> 'auto_fill_amount_enabled' as boolean),
    cast(data ->> 'auto_fill_memo_enabled' as boolean),
    cast(data ->> 'rename_on_import_enabled' as boolean)
  FROM import.be_payees
);

insert into be_transactions (
  SELECT
    data->>'id',
    data->>'ynab_id',
    cast(data->>'is_tombstone' as boolean),
    data->>'source',
    data->>'entities_account_id',
    data->>'entities_payee_id',
    data->>'entities_subcategory_id',
    data->>'entities_scheduled_transaction_id',
    data->>'imported_payee',
    cast(data->>'date' as date),
    cast(data->>'imported_date' as date),
    data->>'date_entered_from_schedule',
    cast(data->>'amount' as integer),
    cast(data->>'cash_amount' as integer),
    cast(data->>'credit_amount' as integer),
    cast(data->>'subcategory_credit_amount_preceding' as integer),
    data->>'memo',
    data->>'cleared',
    cast(data->>'accepted' as boolean),
    data->>'check_number',
    data->>'flag',
    data->>'transfer_account_id',
    data->>'transfer_transaction_id',
    data->>'transfer_subtransaction_id',
    data->>'matched_transaction_id'
  from import.be_transactions
);

insert into be_payee_rename_conditions (
  SELECT
    data->>'id',
    data->>'entities_payee_id',
    cast(data->>'is_tombstone' as boolean),
    data->>'operator',
    data->>'operand'
  from import.be_payee_rename_conditions
);

insert into be_subcategories (id, entities_master_category_id, is_tombstone, internal_name, name, type, sortable_index, note, entities_account_id, goal_type, goal_creation_month, target_balance, target_balance_month, monthly_funding, is_hidden) (
    SELECT
      data->>'id',
      data->>'entities_master_category_id',
      cast(data->>'is_tombstone' as boolean),
      data->>'internal_name',
      data->>'name',
      data->>'type',
      cast(data->>'sortable_index' as integer),
      data->>'note',
      data->>'entities_account_id',
      data->>'goal_type',
      data->>'goal_creation_month',
      cast(data->>'target_balance' as integer),
      data->>'target_balance_month',
      cast(data->>'monthly_funding' as integer),
      cast(data->>'is_hidden' as boolean)
  from import.be_subcategories
);