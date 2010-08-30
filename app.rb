require 'rubygems'
require 'sinatra'

require 'yaml'
require 'erb'
require 'rest-client'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-aggregates'
require 'pony'
require 'json'

configure :development do
  require 'dm-sqlite-adapter'
end

configure :production do
  require 'dm-postgres-adapter'
end

STORE_CONFIG = YAML::load(File.open(File.join(File.dirname(__FILE__), 'config.yml')))

STORE_CERT_APP = File.read(File.join(File.dirname(__FILE__), 'certs/app_cert.pem'))
STORE_CERT_KEY = File.read(File.join(File.dirname(__FILE__), 'certs/app_key.pem'))
STORE_CERT_PAYPAL = File.read(File.join(File.dirname(__FILE__), 'certs/paypal_cert.pem'))

STORE_CERT_SERIAL = File.read(File.join(File.dirname(__FILE__), 'certs/serial_key.pem'))

helpers do
  def encrypt_values(values)
    signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(STORE_CERT_APP), OpenSSL::PKey::RSA.new(STORE_CERT_KEY, ''), values.map { |k, v| "#{ k }=#{ v }" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
    OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(STORE_CERT_PAYPAL)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end

  def valid_purchase?(params)
    purchase = RestClient.post STORE_CONFIG[:paypal][:url], params

    if purchase == 'VERIFIED'
      expected = {
        :payment_status => 'Completed'
      }
      expected.keys.all? { |key| params[key] == expected[key] }
    end
  end

  def generate_serial_num
    rand(2**256).to_s(36)[0..24].upcase.scan(/.{5}/).to_a.join('-')
  end

  def email_registration(registration)
    Pony.mail(
      :to               => 'max@bylinebreak.com',
      :cc               => 'max@bylinebreak.com',
      :from             => '"BaseApp" <no-reply@getbaseapp.com>',
      :subject          => "Baseapp 1.x Serial",
      :body             => "This is your beautiful serial: #{ registration[:serial_num] }",
      :via => :smtp,
      :via_smtp => {
        :address          => 'smtp.sendgrid.net',
        :port             => '25',
        :authentication   => :plain,
        :user_name        => ENV['SENDGRID_USERNAME'],
        :password         => ENV['SENDGRID_PASSWORD'],
        :domain           => ENV['SENDGRID_DOMAIN']
      }
    )
  end
end

DataMapper.setup(:default, (ENV["DATABASE_URL"] ||  "sqlite3://#{Dir.pwd}/development.sqlite"))

class Registration
  include DataMapper::Resource

  property :transaction,    String, :length => 255, :key => true
  property :created_at,     DateTime
  property :serial_num,     String, :length => 255
  property :email,          String, :length => 255
end

DataMapper.auto_upgrade!

get '/home/?' do
  @form = { :action => STORE_CONFIG[:paypal][:url], :encrypted => encrypt_values(STORE_CONFIG[:paypal][:form]) }

  erb :home
end

get '/thanks/?' do
  "You will get an email with your serial as soon as the Paypal goblins process your payment."
end

get '/cancel/?' do
  "Oh noes, you didn't."
end

post '/ipn/?' do
  params.update :cmd => '_notify-validate'

  if valid_purchase?(params)
    registration = Registration.new(:transaction => params[:txn_id], :serial_num => generate_serial_num, :email => params[:payer_email])

    if registration.save
      email_registration(registration)
    end
  end
end

get '/activate/?' do
  error(404, "Serial doesn't exist.") if Registration.count(:serial_num => params[:serial_num]) == 0

  json_string = { :serial_num => params[:serial_num] }.to_json
  OpenSSL::PKey::RSA.new(STORE_CERT_SERIAL).private_encrypt(json_string)
end
