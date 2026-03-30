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

  def app_name
    "Dayspring IPL Prediction"
  end

  def admin_area?
    controller_path.start_with?("admin/")
  end

  def site_navigation_items
    items = [
      { label: "Match Center", path: root_path, active: controller_name == "dashboard" },
      { label: "Leaderboard", path: leaderboards_path, active: controller_name == "leaderboards" }
    ]

    items << {
      label: "History",
      path: prediction_history_path,
      active: controller_name == "prediction_histories"
    } if user_signed_in?

    items << {
      label: "Admin",
      path: admin_root_path,
      active: admin_area?
    } if current_user&.admin?

    items
  end

  def admin_navigation_items
    [
      { label: "Matches", path: admin_root_path, active: controller_path == "admin/matches" },
      { label: "Prediction Logs", path: admin_prediction_submissions_path, active: controller_path == "admin/prediction_submissions" },
      { label: "Activity Logs", path: admin_activity_logs_path, active: controller_path == "admin/activity_logs" }
    ]
  end

  def nav_link_classes(active: false)
    class_names(
      "inline-flex items-center rounded-full border px-4 py-2 text-sm font-medium transition",
      active ?
        "border-white bg-white text-slate-950 shadow-lg shadow-slate-950/25" :
        "border-white/12 bg-white/5 text-slate-200 hover:border-white/25 hover:bg-white/10 hover:text-white"
    )
  end

  def admin_nav_link_classes(active: false)
    class_names(
      "inline-flex items-center rounded-full px-4 py-2 text-sm font-medium transition",
      active ?
        "bg-amber-300 text-slate-950 shadow-lg shadow-amber-950/20" :
        "bg-white/6 text-slate-200 hover:bg-white/12 hover:text-white"
    )
  end

  def button_classes(variant: :primary, size: :md, block: false)
    base = "inline-flex items-center justify-center rounded-full font-medium transition focus-visible:outline-none focus-visible:ring-4 disabled:cursor-not-allowed disabled:opacity-50"
    size_classes = {
      sm: "px-3 py-2 text-sm",
      md: "px-4 py-2.5 text-sm",
      lg: "px-5 py-3 text-base"
    }.fetch(size)
    variant_classes = {
      primary: "bg-slate-950 text-white shadow-lg shadow-slate-950/20 hover:bg-slate-800 focus-visible:ring-slate-200",
      secondary: "border border-slate-200 bg-white text-slate-800 hover:border-slate-300 hover:bg-slate-50 focus-visible:ring-slate-200",
      accent: "bg-amber-300 text-slate-950 shadow-lg shadow-amber-950/10 hover:bg-amber-200 focus-visible:ring-amber-200",
      subtle: "bg-white/70 text-slate-700 hover:bg-white focus-visible:ring-slate-200",
      danger: "bg-rose-600 text-white shadow-lg shadow-rose-950/15 hover:bg-rose-500 focus-visible:ring-rose-200"
    }.fetch(variant)

    class_names(base, size_classes, variant_classes, "w-full" => block)
  end

  def field_classes(invalid: false)
    class_names(
      "block w-full rounded-3xl border bg-white/95 px-4 py-3 text-sm text-slate-900 shadow-sm outline-none transition placeholder:text-slate-400 focus:ring-4",
      invalid ?
        "border-rose-300 focus:border-rose-400 focus:ring-rose-100" :
        "border-slate-200 focus:border-amber-300 focus:ring-amber-100"
    )
  end

  def textarea_classes(invalid: false)
    class_names(field_classes(invalid: invalid), "min-h-32")
  end

  def checkbox_classes
    "h-4 w-4 rounded border-slate-300 text-slate-900 focus:ring-amber-400"
  end

  def pill_classes(tone: :neutral)
    class_names(
      "inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold tracking-wide",
      {
        neutral: "bg-slate-100 text-slate-600",
        accent: "bg-amber-100 text-amber-900",
        success: "bg-emerald-100 text-emerald-800",
        warning: "bg-orange-100 text-orange-900",
        danger: "bg-rose-100 text-rose-800",
        dark: "bg-slate-900 text-white",
        info: "bg-sky-100 text-sky-800"
      }.fetch(tone)
    )
  end

  def flash_message_classes(type)
    class_names(
      "rounded-[1.75rem] border px-5 py-4 shadow-lg backdrop-blur-sm",
      type.to_s == "notice" ?
        "border-emerald-200 bg-emerald-50/95 text-emerald-900" :
        "border-rose-200 bg-rose-50/95 text-rose-900"
    )
  end

  def surface_classes(tone: :default)
    class_names(
      "rounded-[2rem] border shadow-[0_30px_80px_-42px_rgba(15,23,42,0.45)]",
      {
        default: "border-white/70 bg-white/92",
        muted: "border-slate-200/80 bg-slate-50/95",
        dark: "border-white/10 bg-slate-950/92 text-white"
      }.fetch(tone)
    )
  end

  def form_error_message(record, attribute)
    return unless record&.errors&.include?(attribute)

    record.errors.full_messages_for(attribute).first
  end

  def user_handle(user)
    user.email.to_s.split("@").first.tr("._", " ").squish.titleize
  end

  def team_logo(team_name, size: "h-14 w-14")
    logo_url = TEAM_LOGO_URLS[team_name]
    wrapper_classes = class_names(
      "inline-flex items-center justify-center rounded-[1.25rem] border border-white/70 bg-white p-2 shadow-sm",
      size
    )

    if logo_url.present?
      content_tag(:span, class: wrapper_classes) do
        image_tag(logo_url, alt: "#{team_name} logo", class: "h-full w-full object-contain")
      end
    else
      content_tag(:span, team_name.to_s.first(2).upcase, class: class_names(wrapper_classes, "font-semibold text-slate-900"))
    end
  end

  def india_time(time)
    time&.in_time_zone(INDIA_TIME_ZONE)
  end

  def format_india_time(time, pattern)
    india_time(time)&.strftime(pattern)
  end
end
