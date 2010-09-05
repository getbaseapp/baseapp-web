require 'rubygems'
require 'sinatra'

require 'yaml'
require 'erb'
require 'rest-client'
require 'sinatra/activerecord'
require 'pony'
require 'json'

require 'auth'

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
    params.update :cmd => '_notify-validate'
    purchase = RestClient.post STORE_CONFIG[:paypal][:url], params

    if purchase == 'VERIFIED'
      expected = {
        :payment_status => 'Completed',
        :receiver_email => STORE_CONFIG[:paypal][:form][:business],
        :mc_gross => STORE_CONFIG[:paypal][:form][:amount]
      }
      expected.keys.all? { |key| params[key] == expected[key] }
    end
  end

  def generate_serial_num
    rand(2**256).to_s(36)[0..24].upcase.scan(/.{5}/).to_a.join('-')
  end

  def email_registration(registration)
    Pony.mail(
      :to               => registration[:email],
      :bcc              => 'mschoening@me.com',
      :from             => '"BaseApp" <support@getbaseapp.com>',
      :subject          => "Your Baseapp Order (#{ registration[:transaction] })",
      :body             => erb(:registration),
      :via => :smtp,
      :smtp => {
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

set :database, ENV["DATABASE_URL"] || "sqlite://development.db"

class Registration < ActiveRecord::Base
  validates_uniqueness_of :transaction
end

get '/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  @message = { :title => "Coming Soon", :content => "We are working hard to release BaseApp soon.", :home => false }

  erb :message
end

get '/home/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  @form = { :action => STORE_CONFIG[:paypal][:url], :encrypted => encrypt_values(STORE_CONFIG[:paypal][:form]) }

  erb :home
end

get '/faq/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  erb :faq
end

get '/thanks/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  @message = { :title => "Thank you for your purchase", :content => "Your serial number will be sent to your Paypal email address.", :home => true }

  erb :message
end

get '/cancel/?' do
  response.headers['Cache-Control'] = 'public, max-age=31557600'

  @message = { :title => "Order Cancelled", :content => "Your order has been cancelled and you will not be billed.", :home => true }

  erb :message
end

post '/ipn/?' do
  error(404, "Purchase not valid.") unless valid_purchase?(params)

  @registration = Registration.new(:transaction => params[:txn_id], :serial_num => generate_serial_num, :email => params[:payer_email])

  if @registration.save
    email_registration(@registration)
  end
end

get '/activate/?' do
  error(404, "Serial doesn't exist.") unless Registration.exists?(:serial_num => params[:serial_num])

  json_string = { :serial_num => params[:serial_num] }.to_json
  OpenSSL::PKey::RSA.new(STORE_CERT_SERIAL).private_encrypt(json_string)
end

get '/admin' do
  ensure_authenticated

  erb :admin
end

post '/admin' do
  ensure_authenticated

  @registration = Registration.new(:transaction => "promo_#{ Time.now.to_i }", :serial_num => generate_serial_num, :email => params[:email])

  if @registration.save
    email_registration(@registration) unless params[:send_as_email].nil?
  end

  erb :admin
end
