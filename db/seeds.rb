production_seed_marker = {
  team_one: "Kolkata Knight Riders",
  team_two: "Delhi Capitals",
  starts_at: Time.zone.local(2026, 5, 24, 19, 30)
}

seed_admin_email = "dhishan@dayspringlabs.com"
seed_player_email = "dhishan@dayspringlabs.com"

if Rails.env.production? && Match.exists?(production_seed_marker)
  puts "Production seed data already exists. Skipping."
else
  seed_admin_password = ENV["SEED_ADMIN_PASSWORD"].presence
  seed_user_password = ENV["SEED_USER_PASSWORD"].presence

  if seed_admin_password.blank? || seed_user_password.blank?
    abort "SEED_ADMIN_PASSWORD and SEED_USER_PASSWORD are required to load seed data."
  end

  PredictionSubmission.destroy_all
  Prediction.destroy_all
  PredictionQuestion.update_all(correct_option_id: nil)
  Match.destroy_all
  User.destroy_all

  admin = User.create!(
    email: seed_admin_email,
    password: seed_admin_password,
    password_confirmation: seed_admin_password,
    admin: true
  )

  player = User.create!(
    email: seed_player_email,
    password: seed_user_password,
    password_confirmation: seed_user_password
  )

fixtures = [
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Sunrisers Hyderabad",
    venue: "Bengaluru",
    starts_at: Time.zone.local(2026, 3, 28, 19, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Kolkata Knight Riders",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 3, 29, 19, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Chennai Super Kings",
    venue: "Guwahati",
    starts_at: Time.zone.local(2026, 3, 30, 19, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Gujarat Titans",
    venue: "New Chandigarh",
    starts_at: Time.zone.local(2026, 3, 31, 19, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Delhi Capitals",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 4, 1, 19, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Sunrisers Hyderabad",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 4, 2, 19, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Punjab Kings",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 4, 3, 19, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Mumbai Indians",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 4, 4, 15, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Rajasthan Royals",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 4, 4, 19, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Lucknow Super Giants",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 4, 5, 15, 30)
  },
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Chennai Super Kings",
    venue: "Bengaluru",
    starts_at: Time.zone.local(2026, 4, 5, 19, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Punjab Kings",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 4, 6, 19, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Mumbai Indians",
    venue: "Guwahati",
    starts_at: Time.zone.local(2026, 4, 7, 19, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Gujarat Titans",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 4, 8, 19, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Lucknow Super Giants",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 4, 9, 19, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Royal Challengers Bengaluru",
    venue: "Guwahati",
    starts_at: Time.zone.local(2026, 4, 10, 19, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Sunrisers Hyderabad",
    venue: "New Chandigarh",
    starts_at: Time.zone.local(2026, 4, 11, 15, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Delhi Capitals",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 4, 11, 19, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Gujarat Titans",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 4, 12, 15, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Royal Challengers Bengaluru",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 4, 12, 19, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Rajasthan Royals",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 4, 13, 19, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Kolkata Knight Riders",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 4, 14, 19, 30)
  },
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Lucknow Super Giants",
    venue: "Bengaluru",
    starts_at: Time.zone.local(2026, 4, 15, 19, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Punjab Kings",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 4, 16, 19, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Kolkata Knight Riders",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 4, 17, 19, 30)
  },
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Delhi Capitals",
    venue: "Bengaluru",
    starts_at: Time.zone.local(2026, 4, 18, 15, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Chennai Super Kings",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 4, 18, 19, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Rajasthan Royals",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 4, 19, 15, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Lucknow Super Giants",
    venue: "New Chandigarh",
    starts_at: Time.zone.local(2026, 4, 19, 19, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Mumbai Indians",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 4, 20, 19, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Delhi Capitals",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 4, 21, 19, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Rajasthan Royals",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 4, 22, 19, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Chennai Super Kings",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 4, 23, 19, 30)
  },
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Gujarat Titans",
    venue: "Bengaluru",
    starts_at: Time.zone.local(2026, 4, 24, 19, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Punjab Kings",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 4, 25, 15, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Sunrisers Hyderabad",
    venue: "Jaipur",
    starts_at: Time.zone.local(2026, 4, 25, 19, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Chennai Super Kings",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 4, 26, 15, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Kolkata Knight Riders",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 4, 26, 19, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Royal Challengers Bengaluru",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 4, 27, 19, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Rajasthan Royals",
    venue: "New Chandigarh",
    starts_at: Time.zone.local(2026, 4, 28, 19, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Sunrisers Hyderabad",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 4, 29, 19, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Royal Challengers Bengaluru",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 4, 30, 19, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Delhi Capitals",
    venue: "Jaipur",
    starts_at: Time.zone.local(2026, 5, 1, 19, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Mumbai Indians",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 5, 2, 19, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Kolkata Knight Riders",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 5, 3, 15, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Punjab Kings",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 5, 3, 19, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Lucknow Super Giants",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 5, 4, 19, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Chennai Super Kings",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 5, 5, 19, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Punjab Kings",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 5, 6, 19, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Royal Challengers Bengaluru",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 5, 7, 19, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Kolkata Knight Riders",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 5, 8, 19, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Gujarat Titans",
    venue: "Jaipur",
    starts_at: Time.zone.local(2026, 5, 9, 19, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Lucknow Super Giants",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 5, 10, 15, 30)
  },
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Mumbai Indians",
    venue: "Raipur",
    starts_at: Time.zone.local(2026, 5, 10, 19, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Delhi Capitals",
    venue: "Dharamshala",
    starts_at: Time.zone.local(2026, 5, 11, 19, 30)
  },
  {
    team_one: "Gujarat Titans",
    team_two: "Sunrisers Hyderabad",
    venue: "Ahmedabad",
    starts_at: Time.zone.local(2026, 5, 12, 19, 30)
  },
  {
    team_one: "Royal Challengers Bengaluru",
    team_two: "Kolkata Knight Riders",
    venue: "Raipur",
    starts_at: Time.zone.local(2026, 5, 13, 19, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Mumbai Indians",
    venue: "Dharamshala",
    starts_at: Time.zone.local(2026, 5, 14, 19, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Chennai Super Kings",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 5, 15, 19, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Gujarat Titans",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 5, 16, 19, 30)
  },
  {
    team_one: "Punjab Kings",
    team_two: "Royal Challengers Bengaluru",
    venue: "Dharamshala",
    starts_at: Time.zone.local(2026, 5, 17, 15, 30)
  },
  {
    team_one: "Delhi Capitals",
    team_two: "Rajasthan Royals",
    venue: "Delhi",
    starts_at: Time.zone.local(2026, 5, 17, 19, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Sunrisers Hyderabad",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 5, 18, 15, 30)
  },
  {
    team_one: "Rajasthan Royals",
    team_two: "Lucknow Super Giants",
    venue: "Jaipur",
    starts_at: Time.zone.local(2026, 5, 19, 19, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Mumbai Indians",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 5, 20, 19, 30)
  },
  {
    team_one: "Chennai Super Kings",
    team_two: "Gujarat Titans",
    venue: "Chennai",
    starts_at: Time.zone.local(2026, 5, 21, 19, 30)
  },
  {
    team_one: "Sunrisers Hyderabad",
    team_two: "Royal Challengers Bengaluru",
    venue: "Hyderabad",
    starts_at: Time.zone.local(2026, 5, 22, 19, 30)
  },
  {
    team_one: "Lucknow Super Giants",
    team_two: "Punjab Kings",
    venue: "Lucknow",
    starts_at: Time.zone.local(2026, 5, 23, 19, 30)
  },
  {
    team_one: "Mumbai Indians",
    team_two: "Rajasthan Royals",
    venue: "Mumbai",
    starts_at: Time.zone.local(2026, 5, 24, 15, 30)
  },
  {
    team_one: "Kolkata Knight Riders",
    team_two: "Delhi Capitals",
    venue: "Kolkata",
    starts_at: Time.zone.local(2026, 5, 24, 19, 30)
  }
]

  fixtures.each_with_index do |match_attrs, index|
    match = Match.create!(match_attrs)

    winner_question = match.prediction_questions.create!(
      prompt: "Which team will win the match?",
      point_value: 1
    )
    toss_question = match.prediction_questions.create!(
      prompt: "Who will win the toss?",
      point_value: 1
    )

    [match.team_one, match.team_two].each_with_index do |team_name, option_index|
      winner_question.options.create!(label: team_name, position: option_index)
      toss_question.options.create!(label: team_name, position: option_index)
    end

    next unless index.zero?

    player.predictions.new(prediction_question: winner_question, prediction_option: winner_question.options.first).save!(validate: false)
    player.predictions.new(prediction_question: toss_question, prediction_option: toss_question.options.first).save!(validate: false)

    winner_question.update!(correct_option: winner_question.options.first, result_published_at: Time.current)
    toss_question.update!(correct_option: toss_question.options.last, result_published_at: Time.current)
  end

  puts "Created admin login: #{admin.email}"
  puts "Created player login: #{player.email}"
end
