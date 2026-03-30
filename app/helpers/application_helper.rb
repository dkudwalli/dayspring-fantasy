module ApplicationHelper
  INDIA_TIME_ZONE = "Asia/Kolkata".freeze

  TEAM_LOGO_URLS = {
    "Royal Challengers Bengaluru" => "/team_logos/royal-challengers-bengaluru.png",
    "Sunrisers Hyderabad" => "/team_logos/sunrisers-hyderabad.webp",
    "Mumbai Indians" => "/team_logos/mumbai-indians.svg",
    "Kolkata Knight Riders" => "/team_logos/kolkata-knight-riders.png",
    "Chennai Super Kings" => "/team_logos/chennai-super-kings.png",
    "Rajasthan Royals" => "/team_logos/rajasthan-royals.jpg",
    "Punjab Kings" => "/team_logos/punjab-kings.png",
    "Delhi Capitals" => "/team_logos/delhi-capitals.png",
    "Lucknow Super Giants" => "/team_logos/lucknow-super-giants.png",
    "Gujarat Titans" => "/team_logos/gujarat-titans.svg"
  }.freeze

  def team_logo(team_name)
    logo_url = TEAM_LOGO_URLS[team_name]

    if logo_url.present?
      image_tag(logo_url, alt: "#{team_name} logo", class: "team-logo")
    else
      content_tag(:span, team_name.to_s.first(2).upcase, class: "team-mark")
    end
  end

  def india_time(time)
    time&.in_time_zone(INDIA_TIME_ZONE)
  end

  def format_india_time(time, pattern)
    india_time(time)&.strftime(pattern)
  end
end
