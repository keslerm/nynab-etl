require 'unirest'
require 'yaml'
require 'securerandom'
require 'json'

# Incoming hack
class YNAB
  def initialize
    @url_login = 'https://app.youneedabudget.com/users/login'
    @url_catalog = 'https://app.youneedabudget.com/api/v1/catalog'
    @device_id = SecureRandom.uuid

    # Load login details
    config = YAML.load_file 'config.yml'

    @login_hash = {
        email: config['ynab']['username'],
        password: config['ynab']['password'],
        remember_me: true,
        device_info: {
            id: @device_id
        }
    }
  end

  def login
    @login_response = Unirest.post @url_catalog,
                            parameters: {
                                :operation_name => 'loginUser',
                                :request_data => @login_hash.to_json
                            },
                            headers: {
                                'X-YNAB-Device-Id' => @device_id,
                                'User-Agent' => 'Ruby Export Utility'
                            }
  end

  def export_data
    # Build request object
    request = {
        budget_version_id: @login_response.body['budget_version']['id'],
        starting_device_knowledge: 0,
        ending_device_knowledge: 0,
        device_knowledge_of_server: 0,
        calculated_entities_included: false,
        changed_entities: {}
    }

    headers = {
        'User-Agent' => 'Ruby Export Utility',
        'Cookie' => @login_response.headers[:set_cookie][0],
        'X-Session-Token' => @login_response.body['session_token'],
        'X-YNAB-Device-Id' => @device_id,
        'X-YNAB-Client-Request-Id' => SecureRandom.uuid,
        #'X-YNAB-Client-App-Version' => 'v1.11838',
        'Accept' => 'application/json'
    }


    response = Unirest.post @url_catalog,
                            parameters: {
                                :operation_name => 'syncBudgetData',
                                :request_data => request.to_json
                            },
                            headers: headers
    output = File.open 'output.json', 'wb'
    output.write response.body.to_json
    output.close
  end
end

client = YNAB.new
client.login
client.export_data
