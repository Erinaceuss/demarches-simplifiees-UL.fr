class User < ApplicationRecord
  include CredentialsSyncableConcern
  include EmailSanitizableConcern

  enum loged_in_with_france_connect: {
    particulier: 'particulier',
    entreprise: 'entreprise'
  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :ldap_authenticatable,  :async,
          :rememberable, :trackable, :registerable

  #divise module removed from the roriginal :
  # :confirmable, :database_authenticatable, :registerable, :recoverable, , :validatable

  has_many :dossiers, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :dossiers_invites, through: :invites, source: :dossier
  has_many :piece_justificative, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_one :france_connect_information, dependent: :destroy

  accepts_nested_attributes_for :france_connect_information

  before_validation -> { sanitize_email(:email) }

  # Callback provided by Devise
  def after_confirmation
    link_invites!
  end

  def owns?(dossier)
    dossier.user_id == id
  end

  def invite?(dossier_id)
    invites.pluck(:dossier_id).include?(dossier_id.to_i)
  end

  def owns_or_invite?(dossier)
    owns?(dossier) || invite?(dossier.id)
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

  private

  def link_invites!
    Invite.where(email: email).update_all(user_id: id)
  end


end
