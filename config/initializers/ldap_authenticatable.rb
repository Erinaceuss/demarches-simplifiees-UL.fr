require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise

  module Models
    module LdapAuthenticatable
      extend ActiveSupport::Concern
    end
  end

  module Strategies

    class LdapAuthenticatable < Authenticatable

      def valid?
        true
      end

      def authenticate!
        #pas la permission
        #params.require(:user).permit(:encrypted_password,:login,:remember_me)
        if params[:user]
        File.write('custom.log','params de ldap enthenticatable')
        File.write('custom.log',params)

        @config = YAML::load_file("#{Rails.root.to_s}/config/secret_config.yml")
        host =@config['host']
        port = @config['port']
        base = @config['base']
        appusername=@config['ldapuser']
        apppassword=@config['ldappass']

          puts'_____________'
          puts params


        puts 'CCCCCCCCCCCCCCCCCCCCCCCCC'
        mdpuser =params[:user]['encrypted_password']
          loginuser = params[:user]['login']


        puts loginuser
        puts mdpuser

          @credentials = {
            :method => :simple,
            :username => appusername ,# a user w/sufficient privileges to read from AD goes here,
            :password => apppassword # the user's password goes here

          }
          Net::LDAP.open(:host => host, :port => port,
                         :encryption => :simple_tls,
                         :base => base,
                         :auth => @credentials) do |ldap|



            @credentialsUser = {
              :method => :simple,
              :username => 'uid='+loginuser+',ou=people,dc=univ-lorraine,dc=fr' ,# login of user to auth
              :password => ''+mdpuser # the user's password goes here

            }

            puts 'bind????????????'
            puts ldap.bind(@credentialsUser)

            if ldap.bind(@credentialsUser)
              user = User.find_or_create_by(login: loginuser)
              success!(user)
            else
              fail(:invalid_login)
            end
          end

        else
           fail
        end



      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)

Devise.add_module(:ldap_authenticatable,
                  route: :session,
                  strategy: true,
                  controller: :user_sessions,
                  model: 'ldap_authenticatable')



