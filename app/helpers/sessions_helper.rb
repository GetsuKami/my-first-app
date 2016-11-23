module SessionsHelper

# log in user
	def log_in(user)
		session[:user_id] = user.id
	end

#return user in session(now)(unless without)
	def current_user
		if(user_id = session[:user_id]) # have user log in
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id])
			
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end	

# if user log in ,return true, else return false
	def logged_in?
 		!current_user.nil?
	end

# exit user
	def log_out
		session.delete(:user_id)
		@current_user = nil
	end

#remember user in session
	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	def forget(user)
		user.forget # user.rb method # reset user table remember_digest nil
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end

	def log_out
		forget(current_user)
		session.delete(:user_id) #delete session
		@current_user = nil
	end

end