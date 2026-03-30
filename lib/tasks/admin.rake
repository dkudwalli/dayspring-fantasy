namespace :admin do
  desc "Create or promote an admin user. Requires ADMIN_EMAIL and ADMIN_PASSWORD."
  task bootstrap: :environment do
    email = ENV.fetch("ADMIN_EMAIL").to_s.strip.downcase
    password = ENV.fetch("ADMIN_PASSWORD")

    user = User.find_or_initialize_by(email: email)
    user.password = password
    user.password_confirmation = password
    user.admin = true
    user.save!

    puts "Admin user ready: #{user.email}"
  end
end
