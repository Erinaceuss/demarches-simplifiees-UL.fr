class Administration < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :omniauthable, :async, omniauth_providers: [:github]

  def self.from_omniauth(params)
    find_by(email: params["info"]["email"])
  end

  def invite_admin(email)
    password = SecureRandom.hex
    administrateur = Administrateur.new({
      email: email,
      active: false,
      password: password,
      password_confirmation: password
    })

    if administrateur.save
      AdministrationMailer.new_admin_email(administrateur, self).deliver_later
      administrateur.invite!(id)

      User.create({
        email: email,
        password: password,
        confirmed_at: Time.zone.now
      })

      Gestionnaire.create({
        email: email,
        password: password
      })
    end

    administrateur
  end

  def checkpssldap!(psw)
    #if params[:user]
    File.write('custom.log','params de ldap enthenticatable')
    File.write('custom.log',self)

    @config = YAML::load_file("#{Rails.root.to_s}/config/secret_config.yml")
    host =@config['host']
    port = @config['port']
    base = @config['base']
    appusername=@config['ldapuser']
    apppassword=@config['ldappass']




    puts 'CCCCCCCCCCCCCCCCCCCCCCCCC'
    mdpuser =psw
    loginuser = self.login


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
        true
      else
        false
      end
    end
    #else
    # false
    #end
  end
end
