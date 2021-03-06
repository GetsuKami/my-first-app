class User < ApplicationRecord

	has_many :microposts, dependent: :destroy

	attr_accessor :remember_token, :activation_token

	before_save :downcase_email  
	before_create :create_activation_digest

	validates :name, presence: true , length: { maximum: 20}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }


	has_secure_password       
	validates :password, presence: true, length: { in: 6..20 } , allow_nil: true            


	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest,User.digest(remember_token))
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	#　激活账户
	def activate
		update_columns(activated: true, activated_at: Time.now)
	end

	# 发送激活邮件
	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

private

		# 创建并赋值激活令牌和摘要
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end
		# 将大写email 转换成小写
		def downcase_email
			self.email = email.downcase
		end

	class << self

		def digest(string)		
			cost  = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
			BCrypt::Password.create(string, cost: cost)                                                  
		end
	
		def new_token
			SecureRandom.urlsafe_base64
		end	
	end
end
